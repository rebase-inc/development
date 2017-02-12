
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

function _force_rebuild_python_services () {
    services_dirs=(api python-2-parser python-parser github-scanner population-analyzer python-impact workbench)
    for service in ${services_dirs[@]}; do
        echo >> services/$service/requirements.txt
    done
    _build api python_2_parser python_parser python_impact public_github_scanner private_github_scanner population_analyzer workbench
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
