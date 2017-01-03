#!/usr/bin/env bash
#docker exec -t api /venv/web/bin/python -m rebase.scripts.manage data drop --yes
docker exec -t api /venv/web/bin/python -m rebase.scripts.manage data create
