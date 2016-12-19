To get started after you've cloned this repo
```bash
docker -v
docker-compose -v
docker-machine create --driver vmware default # or replace default with your choice of name
eval $(docker-machine env default) # or replace default with the name used above
./tools/make-env.bash
. ~/.rebase.env # or wherver you told make-env.bash to put your file
git submodule init && git submodule update
docker-compose -f compose/pypi-server.yml up --build -d
docker-compose -f compose/common.yml -f compose/dev.yml up --build -d
./tools/init-db.bash
```
