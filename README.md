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
