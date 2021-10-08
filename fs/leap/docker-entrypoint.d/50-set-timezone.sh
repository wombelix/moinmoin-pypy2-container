#!/bin/bash
#
# SPDX-FileCopyrightText: openSUSE / opensuse-nginx-image
# SPDX-License-Identifier: MIT
#
set -e

DEBUG=${DEBUG:-"0"}
[ "${DEBUG}" = "1" ] && set -x

if [ -n "$TZ" ]; then
    TZ_FILE="/usr/share/zoneinfo/$TZ"
    if [ -f "$TZ_FILE" ]; then
        echo "Setting container timezone to: $TZ"
        ln -snf "$TZ_FILE" /etc/localtime
    else
        echo "Cannot set timezone \"$TZ\": timezone does not exist."
    fi
fi

