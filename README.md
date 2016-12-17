To get started after you've cloned this repo
```bash
git submodule init && git submodule update
docker-compose -f compose/common.yml -f compose/dev.yml up -d
./tools/init-db.bash
```
