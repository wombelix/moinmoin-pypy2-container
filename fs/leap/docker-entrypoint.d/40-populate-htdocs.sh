#!/bin/bash
#
# SPDX-FileCopyrightText: openSUSE / opensuse-nginx-image
# SPDX-License-Identifier: MIT
#
set -e

DEBUG=${DEBUG:-"0"}
[ "${DEBUG}" = "1" ] && set -x

HTDOCS_DIR=/srv/www/htdocs

# populate default nginx configuration if it does not exist
if [ ! "$(ls -A $HTDOCS_DIR)" ]; then
   echo "Populate ${HTDOCS_DIR}"
   cp -a /usr/local/nginx/htdocs/* ${HTDOCS_DIR}/
fi

exit 0
