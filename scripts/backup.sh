#!/bin/bash
set -euo pipefail

## --- Base --- ##
# Getting path of this script file:
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
_PROJECT_DIR="$(cd "${_SCRIPT_DIR}/.." >/dev/null 2>&1 && pwd)"
cd "${_PROJECT_DIR}" || exit 2

# Loading base script:
# shellcheck disable=SC1091
source "${_SCRIPT_DIR}/base.sh"

# Loading .env file:
if [ -f ".env" ]; then
	# shellcheck disable=SC1091
	source .env
fi
## --- Base --- ##


## --- Variables --- ##
# Load from envrionment variables:
BACKUPS_DIR="${BACKUPS_DIR:-./volumes/backups}"
## --- Variables --- ##


## --- Main --- ##
main()
{
	echoInfo "Creating backups of 'stack.nginx'..."
	if [ ! -d "${BACKUPS_DIR}" ]; then
		mkdir -pv "${BACKUPS_DIR}" || exit 2
	fi

	tar -czpvf "${BACKUPS_DIR}/stack.nginx.$(date -u '+%y%m%d_%H%M%S').tar.gz" -C ./volumes ./storage || exit 2
	echoOk "Done."
}

main "${@:-}"
## --- Main --- ##
