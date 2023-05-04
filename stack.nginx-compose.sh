#!/bin/bash
set -euo pipefail


## --- Base --- ##
# Getting path of this script file:
_PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "${_PROJECT_DIR}" || exit 2

# Loading base script:
# shellcheck disable=SC1091
source "${_PROJECT_DIR}/scripts/base.sh"

exitIfNoDocker
exitIfNotExists ".env"
## --- Base --- ##


## --- Variables --- ##
# Extending timeout of docker compose logs:
export COMPOSE_HTTP_TIMEOUT=43200

_DEFAULT_SERVICE="nginx"
## --- Variables --- ##


## --- Functions --- ##
_doValidate()
{
	docker compose config || exit 2
}

_doStart()
{
	if [ "${1:-}" == "-l" ]; then
		shift
		# shellcheck disable=SC2068
		docker compose up -d ${@:-} || exit 2
		_doLogs "${@:-}"
	else
		# shellcheck disable=SC2068
		docker compose up -d ${@:-} || exit 2
	fi
}

_doStop()
{
	if [ -z "${1:-}" ]; then
		docker compose down || exit 2
	else
		# shellcheck disable=SC2068
		docker compose rm -sfv ${@:-} || exit 2
	fi
}

_doRestart()
{
	_doStop "${@:-}" || exit 2
	_doStart "${@:-}" || exit 2
	# docker compose restart ${@:-} || exit 2
}

_doLogs()
{
	if [ -n "${1:-}" ]; then
		# docker compose logs -f --tail 100 ${@} || exit 2
		# shellcheck disable=SC2068
		docker compose ps -q ${@} | xargs -n 1 docker logs -f -n 100 || exit 2
	else
		docker compose logs -f --tail 100 || exit 2
	fi
}

_doList()
{
	docker compose ps || exit 2
}

_doPs()
{
	# shellcheck disable=SC2068
	docker compose top ${@:-} || exit 2
}

_doStats()
{
	# shellcheck disable=SC2046
	docker stats $(docker compose ps -q) || exit 2
}

_doCerts()
{
	docker compose exec certbot certbot certificates || exit 2
}

_doExec()
{
	if [ -z "${1:-}" ]; then
		echoError "Not found any input."
		exit 1
	fi

	# shellcheck disable=SC2068
	docker compose exec "${_DEFAULT_SERVICE}" ${@} || exit 2
}

_doReload()
{
	docker compose exec "${_DEFAULT_SERVICE}" /bin/bash -c "nginx -t && nginx -s reload" || exit 2
}

_doEnter()
{
	_service="${_DEFAULT_SERVICE}"
	if [ -n "${1:-}" ]; then
		_service=${1}
	fi

	echoInfo "Entering '${_service}' container..."
	docker compose exec "${_service}" /bin/bash || exit 2
}

_doImages()
{
	# shellcheck disable=SC2068
	docker compose images ${@:-} || exit 2
}

_doUpdate()
{
	if docker compose ps | grep 'Up' > /dev/null 2>&1; then
		_doStop "${@:-}" || exit 2
	fi

	# shellcheck disable=SC2068
	docker compose pull ${@:-} || exit 2
	# shellcheck disable=SC2046
	docker rmi -f $(docker images --filter "dangling=true" -q --no-trunc) > /dev/null 2>&1 || true

	# _doStart "${@:-}" || exit 2
}

_doClean()
{
	if docker compose ps | grep 'Up' > /dev/null 2>&1; then
		_doStop
	fi

	rm -rfv ./volumes/storage/nginx/logs/* ./volumes/storage/certbot/logs/* ./volumes/storage/nginx/ssl/* || exit 2
}
## --- Functions --- ##


## --- Menu arguments --- ##
_exitOnWrongParams()
{
	echoInfo "USAGE: ${0} validate | start | stop | restart | logs | list | ps | stats | exec | certs | reload | enter | images | update | clean"
	exit 1
}

main()
{
	if [ -z "${1:-}" ]; then
		echoError "Not found any input."
		_exitOnWrongParams
	fi

	case ${1} in
		validate | config)
			shift
			_doValidate;;
		start | run)
			shift
			_doStart "${@:-}";;
		stop | remove | rm | delete | del | end)
			shift
			_doStop "${@:-}";;
		restart)
			shift
			_doRestart "${@:-}";;
		logs)
			shift
			_doLogs "${@:-}";;
		list)
			_doList;;
		ps)
			shift
			_doPs "${@:-}";;
		stats | resource | limit)
			shift
			_doStats;;
		exec)
			shift
			_doExec "${@:-}";;
		certs | certificates)
			shift
			_doCerts;;
		reload)
			shift
			_doReload;;
		enter)
			shift
			_doEnter "${@:-}";;
		images)
			shift
			_doImages "${@:-}";;
		update)
			shift
			_doUpdate "${@:-}";;
		clean | clear)
			shift
			_doClean;;
		*)
			echoError "Failed to parsing input: ${*}"
			_exitOnWrongParams;;
	esac

	exit
}

main "${@:-}"
## --- Menu arguments --- ##
