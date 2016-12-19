To get started after you've cloned this repo
```bash
docker -v
docker-compose -v
docker-machine create --driver vmware default # or replace default with your choice of name
eval $(docker-machine env default) # or replace default with the name used above
./tools/make-env.bash
git submodule init && git submodule update
docker-compose -f compose/pypi-server.yml up -d
docker-compose -f compose/common.yml -f compose/dev.yml up -d
./tools/init-db.bash
```
