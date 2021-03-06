#!/bin/bash
#
# SPDX-FileCopyrightText: openSUSE / opensuse-nginx-image
# SPDX-License-Identifier: MIT
#
set -e

DEBUG=${DEBUG:-"0"}
[ "${DEBUG}" = "1" ] && set -x

ETC_DIR=/etc/nginx

# populate default nginx configuration if it does not exist
if [ ! -f ${ETC_DIR}/nginx.conf ]; then
    echo "Populate ${ETC_DIR}"
    cp -a /usr/local/nginx/etc/* ${ETC_DIR}/
fi

exit 0
