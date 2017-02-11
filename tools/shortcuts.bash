
function _c () {
    docker-compose -f compose/common.yml -f compose/dev.yml -f compose/sync.yml $*
}

function _ps () {
    _c ps
}

function _logs () {
    _c logs $*
}

function _build () {
    _c -f compose/build.yml build $*
}

function _x () {
    _c exec $*
}

function _tail () {
    docker exec -t logserver tail -300 -f /var/log/rebase.log | sed 's/#012/\'$'\n''/g'
}

function _sh () {
    _x $1 sh
}

function _bash () {
    _x $1 bash
}

function _api_manage () {
    _x api /venv/web/bin/python -m rebase.scripts.manage $*
}

function _api_shell () {
    _api_manage shell $*
}

function _api_recreate () {
    _api_manage data recreate $*
}
