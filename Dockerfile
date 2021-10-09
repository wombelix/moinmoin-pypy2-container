#
# SPDX-FileCopyrightText: 2021 Dominik Wombacher <dominik@wombacher.cc>
# SPDX-License-Identifier: AGPL-3.0-or-later
#
FROM registry.opensuse.org/opensuse/leap:15.3
LABEL org.opencontainers.image.authors="Dominik Wombacher dominik@wombacher.cc"
LABEL org.opencontainers.image.title="moinmoin-pypy2"
LABEL org.opencontainers.image.description="MoinMoin Wiki powered by pypy2, uswgi, nginx and openSUSE Leap"
LABEL org.opencontainers.image.licenses="AGPL-3.0-or-later"
LABEL org.opencontainers.image.url="https://dominik.wombacher.cc/"
LABEL org.opencontainers.image.documentation="https://codeberg.org/wombelix/moinmoin-pypy2-container/src/branch/main/README.md"
LABEL org.opencontainers.image.source="https://codeberg.org/wombelix/moinmoin-pypy2-container"
LABEL org.opencontainers.image.base.name="registry.opensuse.org/opensuse/leap:15.3"

ENV PYTHONPATH=/usr/local/share/moin

RUN zypper -n --no-refresh in --no-recommends python3-virtualenv python3-pip curl tar bzip2 gzip gcc nginx && \
    cd /usr/local/ && \
    curl https://downloads.python.org/pypy/pypy2.7-v7.3.5-linux64.tar.bz2 -O && \
    tar xfj pypy2.7-v7.3.5-linux64.tar.bz2 && \
    rm -f pypy2.7-v7.3.5-linux64.tar.bz2 && \
    virtualenv -p pypy2.7-v7.3.5-linux64/bin/pypy /usr/local/venv && \
    source /usr/local/venv/bin/activate && \
    cd /tmp && \
    curl http://static.moinmo.in/files/moin-1.9.11.tar.gz -O && \
    tar xfz moin-1.9.11.tar.gz && \
    cd moin-1.9.11 && \
    python setup.py --quiet install && \
    cd /tmp && \
    rm -rf ./moin-1.9.11* && \
    mv /usr/local/venv/share/moin/ /usr/local/share/ && \
    mv /usr/local/share/moin/server/moin.wsgi /usr/local/share/moin/moin.wsgi && \
    rm -rf /usr/local/share/moin/server && \
    rm -rf /usr/local/share/moin/config && \
    pip install --no-cache-dir uwsgi && \
    mkdir -p /usr/local/nginx/etc && \
    cp -av /etc/nginx/* /usr/local/nginx/etc/ && \
    rm -rf /etc/nginx/* && \
    rm /usr/local/nginx/etc/*.default && \
    mkdir -p /usr/local/nginx/htdocs && \
    cp -av /srv/www/htdocs/* /usr/local/nginx/htdocs && \
    zypper -n rm -u python3-virtualenv python3-pip curl tar bzip2 gzip && \
    zypper -n clean --all && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

COPY fs/leap/ /

EXPOSE 443

VOLUME /usr/local/share/moin/

ENTRYPOINT /usr/local/bin/entrypoint.sh
