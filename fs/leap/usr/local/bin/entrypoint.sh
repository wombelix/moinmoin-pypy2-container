#!/bin/bash
#
# SPDX-FileCopyrightText: openSUSE / opensuse-nginx-image
# SPDX-License-Identifier: MIT
#
set -e

DEBUG=${DEBUG:-"0"}
[ "${DEBUG}" = "1" ] && set -x


if /usr/bin/find "/docker-entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
    echo "/docker-entrypoint.d/ is not empty, will attempt to perform configuration"

    echo "Looking for shell scripts in /docker-entrypoint.d/"
    find "/docker-entrypoint.d/" -follow -type f -print | sort -V | while read -r f; do
        case "$f" in
            *.sh)
                if [ -x "$f" ]; then
                    echo "Launching $f";
                    "$f"
                else
                    # warn on shell scripts without exec bit
                    echo "Ignoring $f, not executable";
                fi
                ;;
            *) echo "Ignoring $f";;
        esac
     done

    echo "Configuration complete; ready for start up"
else
    echo "No files found in /docker-entrypoint.d/, skipping configuration"
fi

# allow arguments to be passed to nginx
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == nginx || ${1} == /usr/sbin/nginx ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch nginx
if [[ -z ${1} ]]; then
  echo "Starting nginx..."
  exec /usr/sbin/nginx -g "daemon off;" ${EXTRA_ARGS}
else
  exec "$@"
fi
