To get started...
```bash
git -v
docker -v
docker-compose -v
git clone git@github.com:rebase-inc/development.git && cd development
git submodule init && git submodule update
docker-compose -f compose/common.yml -f compose/dev.yml up -d
```
