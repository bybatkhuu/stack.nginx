#!/bin/bash
set -euo pipefail


## --- Base --- ##
# Getting path of this script file:
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
_PROJECT_DIR="$(cd "${_SCRIPT_DIR}/.." >/dev/null 2>&1 && pwd)"
cd "${_PROJECT_DIR}" || exit 2

# Loading base script:
# shellcheck disable=SC1091
source ./scripts/base.sh

# Loading .env file:
if [ -f ".env" ]; then
	# shellcheck disable=SC1091
	source .env
fi
## --- Base --- ##


## --- Variables --- ##
# Flags:
_IS_ALL=false
## --- Variables --- ##


## --- Main --- ##
main()
{
	## --- Menu arguments --- ##
	if [ -n "${1:-}" ]; then
		for _input in "${@:-}"; do
			case ${_input} in
				-a | --all)
					_IS_ALL=true
					shift;;
				*)
					echoError "Failed to parsing input -> ${_input}"
					echoInfo "USAGE: ${0} -a, --all"
					exit 1;;
			esac
		done
	fi
	## --- Menu arguments --- ##


	if docker compose ps | grep 'Up' > /dev/null 2>&1; then
		echoError "Docker is running. Please stop it before cleaning."
		exit 1
	fi


	echoInfo "Cleaning..."

	find . -type f -name ".DS_Store" -print -delete || exit 2
	find . -type f -name "Thumbs.db" -print -delete || exit 2

	rm -rfv ./volumes/storage/certbot/logs || exit 2
	rm -rfv ./volumes/storage/nginx/logs || exit 2

	if [ "${_IS_ALL}" == true ]; then
		# rm -rfv ./volumes/storage/nginx/ssl/* || exit 2
		rm -rf ./volumes/.vscode-server/* || exit 2
		rm -rfv ./volumes/backups || exit 2

		docker compose down -v --remove-orphans || exit 2
	fi

	echoOk "Done."
}

main "${@:-}"
## --- Main --- ##
