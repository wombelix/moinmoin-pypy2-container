<!--
 SPDX-FileCopyrightText: 2021 Dominik Wombacher <dominik@wombacher.cc>
 SPDX-License-Identifier: CC-BY-SA-4.0
-->
## 0.3.0 (2023-10-10)

### Feat

- Perform moinmoin maintenance tasks on startup
- Replace existing user if env var is set, add option to change sitename

## 0.2.0 (2023-10-09)

### Feat

- upgrade to openSUSE Leap 15.5 and PyPy2.7 v7.3.13

## 0.1.0 (2021-10-09)

### Fix

- '/usr/local/share/moin/' defined as VOLUME to ensure proper handling
- wrong path to ssl key corrected
- wrong version number, adjusted to reflect intial release

### Feat

- logic for inital setup and customizing
- start script to initiate uwsgi process
- optimized wikiconfig and uwsgi config file
- customized nginx config for moinmoin
- optimized dhparam file from mozilla ssl config
- basic entrypoint functionality and defaults
- Dockerfile to build 'moinmoin-pypy2'
