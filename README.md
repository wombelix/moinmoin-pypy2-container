<!--
 SPDX-FileCopyrightText: 2021 Dominik Wombacher <dominik@wombacher.cc>
 SPDX-License-Identifier: CC-BY-SA-4.0
-->
# MoinMoin Wiki Container, powered by pypy2

OCI compliant container image to run MoinMoin wiki, accessible via HTTPS, delivered by nginx and uwsgi.

Ready to use, based on openSUSE Leap and the alternative Python Runtime [PyPy](https://www.pypy.org).

[![Container Repository on Quay](https://quay.io/repository/wombelix/moinmoin-pypy2/status)](https://quay.io/repository/wombelix/moinmoin-pypy2)

# Table of Content

* [Why](#why)
* [Features](#features)
    * [Enhancements](#enhancements)
    * [Variables](#variables)
* [Usage](#usage)
    * [Pull](#pull)
    * [Persistent Volume](#persistent-volume)
    * [Backup and Restore](#backup-and-restore)
    * [Expose Port](#expose-port)
    * [Environment Variables](#environment-variables)
    * [User and Password](#user-and-password)
    * [Custom SSL Certificates](#custom-ssl-certificates)
* [Components](#components)
* [Contribution](#contribution)
* [License](#license)

TOC powered by [github-markdown-toc](https://github.com/ekalinin/github-markdown-toc)

# Why

MoinMoin requires Python 2, the successor [moin2](https://github.com/moinwiki/moin), with Python 3 support, is under development and not released yet. Interested to help and contribute? See: [help wanted](https://github.com/moinwiki/moin/labels/help%20wanted) / [good first issue](https://github.com/moinwiki/moin/labels/good%20first%20issue)

It might be that User still want to keep using the latest stable release and wait with the migration.

The official Python 2 Runtime is [End-of-Life](https://www.python.org/doc/sunset-python-2/) but PyPy will support Python 2 ["forever"](https://doc.pypy.org/en/latest/faq.html#how-long-will-pypy-support-python2) and provide updates in future.

# Features

## Enhancements

- Automatic creation of `superuser`.
- Pre-Installation of `essential_pages` package in english
- Backup feature configured and enabled
- New page `Administration` added to centralize management
    - Create new user accounts
    - Install page packages
    - Create and download a backup
    - Support to set FQDN for nginx (server-name) and self-signed SSL Certificates (common-name)

## Variables

- Manage superuser
    - `MAUSR` = Username, default: MoinAdmin
    - `MAPWD` = Password, default: Random generated and visible via 'stdout' (docker / podman logs)
    - `MAEML` = Email address, default: admin@moinmoin-pypy2.localhost

- Manage nginx / ssl
    - `FQDN` = Servername inklusive Domain, default: moinmoint-pypy2.localhost

# Usage

The following examples were tested with `podman` (3.2.3) in rootless mode on openSUSE Tumbleweed.

## Pull

The pre-build image is available on [quay.io](https://quay.io/repository/wombelix/moinmoin-pypy2?tab=info), you can pull it by running:

```
podman pull quay.io/wombelix/moinmoin-pypy2
```

The container image with label `latest` is based to the last git tag and release. Branches like `main` will not automatically build and uploaded.

## Persistent Volume

All wiki data are located in `/usr/local/share/moin/`, just use the `-v` (--volume) argument to define the `name` as first value (in this example `wiki`), to ensure your data get stored properly and can easy identified later.

```
podman run -d -v wiki:/usr/local/share/moin --name wiki quay.io/wombelix/moinmoin-pypy2
```

You can use `podman volume ls` to show all existing volumes:

```
podman volume ls

DRIVER      VOLUME NAME
local       wiki
```

To get all details about a specific volume (in this example `wiki`) run `podman volume inspect wiki`:
```
[
    {
        "Name": "wiki",
        "Driver": "local",
        "Mountpoint": "/home/wombelix/.local/share/containers/storage/volumes/wiki/_data",
        "CreatedAt": "2021-10-09T12:29:07.76460396+02:00",
        "Labels": {},
        "Scope": "local",
        "Options": {}
    }
]

```

## Backup and Restore

There are a lot of good resources online, one approach can be found in the [Docker Documentation](https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes).

It's up to you which way you choose, at the end it's more or less about a simple file backup. 

Just ensure that the folder mentioned as `Mountpoint` from the `podman volume inspect <volumename>` output (example out, see [Persistent Volume](#persistent-volume) above) is included.

## Expose Port

Inside the Container, nginx is listening on Port 443 for HTTPS requests. Use the `-p` (--publish) argument to define which Host Port should be mapped to the Container (in this example `8443`). This is the Port you going to use when accessing the wiki.

```
podman run -d -p 8443:443 -v wiki:/usr/local/share/moin/ --name wiki quay.io/wombelix/moinmoin-pypy2
```

## Environment Variables

`moinmoin-pypy2` support different environment variables to customize the configuration. To create the superuser `John Doe` with his EMail address `john.doe@example.org`:

```
podman run -d -p 8443:443 -v wiki:/usr/local/share/moin/ --name wiki -e MAUSR=JohnDoe -e MWEML=john.doe@example.org quay.io/wombelix/moinmoin-pypy2
```

You can check the status via `podman logs wiki`, the last argument (`wiki` in this example) depends on the name of your container.

```
/docker-entrypoint.d/ is not empty, will attempt to perform configuration
Looking for shell scripts in /docker-entrypoint.d/
Launching /docker-entrypoint.d/30-populate-etc.sh
Populate /etc/nginx
Launching /docker-entrypoint.d/40-populate-htdocs.sh
Launching /docker-entrypoint.d/50-set-timezone.sh
Launching /docker-entrypoint.d/90-moin.sh
MoinMoin Setup: No user accounts found, superuser 'JohnDoe' will be created.
MoinMoin Setup: Random generated password for 'JohnDoe' -> ONJubT5qg0X72hUL
MoinMoin Setup: Superuser 'JohnDoe' successfully created.
MoinMoin Setup: Custom superuser defined, adjusting configs
MoinMoin Setup: 'MoinAdmin' successfully replaced with 'JohnDoe' in wikiconfig
MoinMoin Setup: 'MoinAdmin' successfully replaced with 'JohnDoe' in 'FrontPage' template
MoinMoin Setup: No pages found, Defaults will be installed ('FrontPage', 'Administration', essential pages package)
MoinMoin Setup: Installation of 'Administration' page successful
MoinMoin Setup: Installation of 'FrontPage' page successful
MoinMoin Setup: Installation of 'essential_pages' package (english) successful
MoinMoin Setup: SSL Certificate successfully generated.
MoinMoin Setup: No custom FQDN defined, skip nginx reconfiguration.
Launching /docker-entrypoint.d/99-uwsgi.sh
Starting uwsgi...
[uWSGI] getting INI configuration from /usr/local/share/moin/uwsgi.ini
Configuration complete; ready for start up
Starting nginx...
```

## User and Password

If you started without existing wiki data, a new `superuser` will be created during the initial setup. You can define a password by setting the environment variable `MAPWD`, otherwise a random password will be generated for you. In this case, you can find it in the `podman logs` output, as in the above `Environment Variables` example.

## Custom SSL Certificates

By default, new self-signed SSL Certificates will be generated during container startup if `/etc/ssl/certs/cert.pem` and `/etc/ssl/private/key.pem` not exist.

You can use your own / already existing certificates as well. In this example the local files `~/wiki/cert.pem` and `~/wiki/key.pem` will be mounted read-only into the Container and used instead the default self-signed certificates.

```
podman run -d -p 8443:443 --name wiki -v ~/wiki/cert.pem:/etc/ssl/certs/cert.pem:ro -v ~/wiki/key.pem:/etc/ssl/private/key.pem:ro quay.io/wombelix/moinmoin-pypy2
```

# Components

- MoinMoin (1.9.11)
- pypy2 (7.3.5, compatible to Python 2.7.18)
- uwsgi (2.0.20)
- openSUSE Leap (15.3)

# Contribution

Please don't hesistate to provide Feedback, open an Issue or create an Pull / Merge Request.

The repository is available on [Codeberg](https://codeberg.org/wombelix/moinmoin-pypy2-container), 
[Gitlab](https://gitlab.com/wombelix/moinmoin-pypy2-container) and 
[Github](https://github.com/wombelix/moinmoin-pypy2-container), 
just pick the platform you are most comfortable with.

# License

Unless otherwise stated: `GNU Affero General Public License v3.0 or later`

All files contain license information either as `header comment` or `corresponding .license` file.

[REUSE](https://reuse.software) from the [FSFE](https://fsfe.org/) implemented to verify license and copyright compliance.