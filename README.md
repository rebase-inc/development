If you're running on a mac, you have two options for running docker: Docker for Mac, or docker-machine.

Only If you're running on Docker for Mac:
```bash
unset ${!DOCKER_*} # only necessary if you've previously had docker-machine installed
sudo ifconfig lo0 alias 10.200.10.1/24 # or replace ip with any unused ip
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
docker-compose -f compose/pypi-server.yml up --build -d
```

To use mounted volumes (easier to understand, but slower development speed):
```bash
docker-compose -f compose/common.yml -f compose/dev.yml -f compose/mount.yml up --build -d
```

To use live reload (if we had really good tests, this probably wouldn't be necessary):
```bash
docker-sync start -c sync/dev.yml # https://github.com/EugenMayer/docker-sync/wiki/1.-Installation
docker-compose -f compose/common.yml -f compose/dev.yml -f compose/sync.yml up --build -d
```

Finally, to initialize the database:
```bash
./tools/init-db.bash
```
