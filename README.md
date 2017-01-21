# Rebase Skills

## Get Started in development mode
If you're running on a mac, you have two options for running docker: Docker for Mac, or docker-machine.

Only If you're running on Docker for Mac (hacks because Docker for Mac isn't quite ready for action):
```bash
unset ${!DOCKER_*} # only necessary if you've previously had docker-machine installed
# See https://docs.docker.com/docker-for-mac/troubleshoot/#/known-issues for details on the following
sudo ifconfig lo0 alias 10.200.10.1/24 # or replace ip with any unused ip - to be able to access host from containers
printf "\n\nserver 127.127.1.1\nfudge  127.127.1.1 stratum 12\n" | sudo tee -a /etc/ntp-restrict.conf >/dev/null # to make sure time in container stays consistent
sudo launchctl unload /System/Library/LaunchDaemons/org.ntp.ntpd.plist
sudo launchctl load /System/Library/LaunchDaemons/org.ntp.ntpd.plist
```

Only if you're running on docker-machine:
```bash
docker-machine create --driver vmware default # or replace default with your choice of name
eval $(docker-machine env default) # or replace default with the name used above
```

For both installation types:
```bash
git submodule init && git submodule update
./tools/make-env.bash
. ~/.rebase.env # or wherver you told make-env.bash to put your file
docker-compose -f compose/python-commons.yml up --build -d
```

To use mounted volumes (easier to understand, but slower development speed):
```bash
docker-compose -f compose/common.yml -f compose/dev.yml -f compose/mount.yml up --build -d
```

To use live reload (if we had really good tests, this probably wouldn't be necessary):
```bash
# https://github.com/EugenMayer/docker-sync/wiki/1.-Installation
docker-sync start -c sync/dev.yml # long running (I usually leave it running in a separate window)
docker-compose -f compose/common.yml -f compose/dev.yml -f compose/sync.yml up --build -d
```

Finally, to initialize the database:
```bash
./tools/init-db.bash
```

And, so you don't forget to push the submodules:
```bash
git config push.recurseSubmodules on-demand
```

## Production 

### Build
Steps are closely related to the development process.
Here's a summary of the differences:
- The UI is compiled into a .js file that is served by Nginx.
- The environment variables have stronger passwords and different credentials.
- The product hostname is different and linked to an official SSL certificate deliverd by Let's Encrypt.
- The Nginx configuration is different
- We use a private Docker Registry to deliver the images. Currently the registry is on the production host.

### How to change the product URL

#### Route53
1. Create Record Set
2. type A, Routing Policy: simple

#### Github
1. go to Rebase Inc.'s settings
2. add a new entry with the proper callback.
For example: skills.rebaseapp.com/api/v1/github/authorized

#### Master environment file
Usually ~/.rebase.env
Update GITHUB_APP_CLIENT_ID & GITHUB_APP_CLIENT_SECRET

#### Nginx
1. Edit ./services/proxy/conf.d/root_pro.conf
2. Locate and update 'server_name' entries

#### SSL Certificates
New domain means new certificates. We use [Let's Encrypt's Certbot](https://certbot.eff.org)

#### New certificate
- launch a shell inside the proxy container
```bash
ssh alpha
. ~/.rebase.env
cd .rebase
docker exec -it proxy bash
```

- Restart Nginx in Let's Encrypt challenge mode
```bash
ln -sf /etc/nginx/conf.d/root_letsencrypt /etc/nginx/nginx.conf
nginx -s reload
```

- Create the certificate
```bash
# first to a dry-run
./certbot-auto --text certonly --test-cert --dry-run --webroot -w /etc/letsencrypt/webrootauth  -d skills.rebaseapp.com

# if dry-run is successful, ask for the real certs
./certbot-auto --text certonly --webroot -w /etc/letsencrypt/webrootauth  -d skills.rebaseapp.com
```

- Renew the certificate (every 90 days)
```bash
# first to a dry-run
./certbot-auto renew --dry-run

# if it works, do the real renewal
./certbot-auto renew
```

- Restart Nginx in HTTPS mode
```bash
ln -sf /etc/nginx/conf.d/root_pro.nginx /etc/nginx/nginx.conf
nginx -s reload
```

- Backup the certs
```bash
# from inside the proxy container
tar -czf /letsencrypt.tar.gz /etc/letsencrypt

# from the production host
docker cp proxy:/letsencrypt.tar.gz ~/.rebase/letsencrypt.tar.gz

# from your laptop
scp alpha:.rebase/letsencrypt.tar.gz ~/Documents/
```

- Produce production proxy images with existing certificates
We need to extract the backup into the proxy build context at ./etc/letsencrypt.
That way, the Dockerfile can copy the previously generated certificates into a
new production image.
```bash
cd ~/repo/development
tar -xvf ~/Documents/Rebase/letsencrypt.tar.gz -C services/proxy
# do a quick ls to make sure the archive was expanded in the right place:
ls -la services/proxy/etc/letsencrypt/live

# now, the next production build will produce an image with the full certificates
cd compose
docker-compose -f common.yml -f pro.yml -f build.yml build proxy
```

