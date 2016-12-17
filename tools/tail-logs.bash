#!/usr/bin/env bash
docker exec -t logserver tail -300 -f /var/log/rebase.log | sed 's/#012/\'$'\n''/g'
