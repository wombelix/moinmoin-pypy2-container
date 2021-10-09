<!--
 SPDX-FileCopyrightText: 2021 Dominik Wombacher <dominik@wombacher.cc>
 SPDX-License-Identifier: CC-BY-SA-4.0
-->
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
