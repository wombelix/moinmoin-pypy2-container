#!/bin/bash
#
# SPDX-FileCopyrightText: 2021 Dominik Wombacher <dominik@wombacher.cc>
# SPDX-License-Identifier: AGPL-3.0-or-later
#
set -e

DEBUG=${DEBUG:-"0"}
[ "${DEBUG}" = "1" ] && set -x

echo "Starting uwsgi..."

source /usr/local/venv/bin/activate && \
uwsgi /usr/local/share/moin/uwsgi.ini
