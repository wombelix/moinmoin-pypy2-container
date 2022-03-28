#!/bin/bash
#
# SPDX-FileCopyrightText: 2021 Dominik Wombacher <dominik@wombacher.cc>
# SPDX-License-Identifier: AGPL-3.0-or-later
#


#
# Get amount of user and pages, necessary to decide later if inital setup is required or not
#
DATAUSERS=$(ls /usr/local/share/moin/data/user | grep -v README | wc -l)
DATAPAGES=$(ls /usr/local/share/moin/data/pages | grep -v BadContent | wc -l)
UNDERLAYPAGES=$(ls /usr/local/share/moin/underlay/pages | grep -v BadContent | grep -v LanguageSetup | wc -l)


#
# Set Defaults
#
SETUPSTR="MoinMoin Setup:"
DEFAULT_MAUSR="MoinAdmin"
DEFAULT_MAEML="admin@moinmoin-pypyp2.localhost"
DEFAULT_FQDN="moinmoin-pypy2.localhost"
DEFAULT_SITENAME="Untitled Wiki"
MOINLOG="/var/log/moin.log"
MOINCFG="/usr/local/share/moin/wikiconfig.py"
MOINFPTPL="/tmp/moinmoin_front.page"
MOINADMTPL="/tmp/moinmoin_administration.page"
MOINPKGBIN="/usr/local/venv/site-packages/MoinMoin/packages.py"
MOINPKGFILE="/usr/local/share/moin/underlay/pages/LanguageSetup/attachments/English--essential_pages.zip"
NGINXCFG="/etc/nginx/vhosts.d/moinmoin.conf"
SSLCRT="/etc/ssl/certs/cert.pem"
SSLKEY="/etc/ssl/private/key.pem"

#
# If no custom values provided, map with defaults
#
if [ -z "$MAUSR" ]; then
  MAUSR=$DEFAULT_MAUSR
fi

if [ -z "$FQDN" ]; then
  FQDN=$DEFAULT_FQDN
fi

if [ -z "$MAEML" ]; then
  MAEML=$DEFAULT_MAEML
fi

if [ -z "$MSITENAME" ]; then
  MSITENAME=$DEFAULT_SITENAME
fi


#
# Load Python Virtual Environment
#
source /usr/local/venv/bin/activate


#
# Setup and configure superuser
#
if [ "$DATAUSERS" = "0" ]; then
  echo "$SETUPSTR No user accounts found, superuser '"$MAUSR"' will be created."

  if [ -z "$MAPWD" ]; then
    MAPWD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)
    echo "$SETUPSTR Random generated password for '"$MAUSR"' -> $MAPWD"
  fi

  moin account create --name="$MAUSR" --password="$MAPWD" --email="$MAEML" --alias="MoinMoin Admin" >> $MOINLOG 2>&1
  RC=$?  

  if [ "$RC" = "0" ]; then
    echo "$SETUPSTR Superuser '"$MAUSR"' successfully created."
  else
    echo "$SETUPSTR Failed to create superuser '"$MAUSR"'. See '"$MOINLOG"' for details."
  fi

else
  echo "$SETUPSTR Existing user accounts found ($DATAUSERS), skip creation of superuser '"$MAUSR"'."
fi


#
# custom superuser
#
if [ "$MAUSR" != "$DEFAULT_MAUSR" ]; then
  echo "$SETUPSTR Custom superuser defined, adjusting configs"

  sed -i "s/$DEFAULT_MAUSR/$MAUSR/g" $MOINCFG
  grep -q $MAUSR $MOINCFG
  RC=$?

  if [ "$RC" = "0" ]; then
    echo "$SETUPSTR '"$DEFAULT_MAUSR"' successfully replaced with '"$MAUSR"' in wikiconfig"
  else
    echo "$SETUPSTR '"$DEFAULT_MAUSR"' could not be replaced with '"$MAUSR"' in wikiconfig. Check '"$MOINCFG"'."
  fi

  sed -i "s/$DEFAULT_MAUSR/$MAUSR/g" $MOINFPTPL
  grep -q $MAUSR $MOINFPTPL
  RC=$?

  if [ "$RC" = "0" ]; then
    echo "$SETUPSTR '"$DEFAULT_MAUSR"' successfully replaced with '"$MAUSR"' in 'FrontPage' template"
  else
    echo "$SETUPSTR '"$DEFAULT_MAUSR"' could not be replaced with '"$MAUSR"' in 'FrontPage' template. Check '"$MOINCFG"'."
  fi
fi


#
# custom sitename
#
if [ "$MSITENAME" != "$DEFAULT_SITENAME" ]; then
  echo "$SETUPSTR Custom sitename defined, adjusting configs"

  sed -i "s/$DEFAULT_SITENAME/$MSITENAME/g" $MOINCFG
  grep -q $MSITENAME $MOINCFG
  RC=$?

  if [ "$RC" = "0" ]; then
    echo "$SETUPSTR '"$DEFAULT_SITENAME"' successfully replaced with '"$MSITENAME"' in wikiconfig"
  else
    echo "$SETUPSTR '"$DEFAULT_SITENAME"' could not be replaced with '"$MSITENAME"' in wikiconfig. Check '"$MOINCFG"'."
  fi
fi


#
# Setup custom pages and install page packages
#
if [ "$DATAPAGES" = "0" ] && [ "$UNDERLAYPAGES" = "0" ]; then
  echo "$SETUPSTR No pages found, Defaults will be installed ('FrontPage', 'Administration', essential pages package)"

  moin import wikipage --page=Administration --author=wombelix --file=$MOINADMTPL >> $MOINLOG 2>&1
  RC=$?

  if [ "$RC" = "0" ]; then
    echo "$SETUPSTR Installation of 'Administration' page successful"
  else
    echo "$SETUPSTR Installation of 'Administration' page failed. See '"$MOINLOG"' for details."
  fi

  moin import wikipage --page=FrontPage --author=wombelix --file=$MOINFPTPL >> $MOINLOG 2>&1
  RC=$?

  if [ "$RC" = "0" ]; then
    echo "$SETUPSTR Installation of 'FrontPage' page successful"
  else
    echo "$SETUPSTR Installation of 'FrontPage' page failed. See '"$MOINLOG"' for details."
  fi

  python $MOINPKGBIN i $MOINPKGFILE >> $MOINLOG 2>&1
  RC=$?

  if [ "$RC" = "0" ]; then
    echo "$SETUPSTR Installation of 'essential_pages' package (english) successful"
  else
    echo "$SETUPSTR Installation of 'essential_pages' package (english) failed. See '"$MOINLOG"' for details."
  fi

else
  echo "$SETUPSTR Existing pages found, skip installation of default pages and packages."
fi


#
# Generate self-signed SSL Certificate
#
if [ ! -r "$SSLCRT" ] && [ ! -r "$SSLKEY" ]; then
  { cd /tmp && \
    openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout key.pem -out cert.pem -subj "/CN="$FQDN"" -days 3650 && \
    mv cert.pem /etc/ssl/certs/ && \
    mv key.pem /etc/ssl/private/; } >> $MOINLOG 2>&1
  RC=$?

  if [ "$RC" = "0" ]; then
    echo "$SETUPSTR SSL Certificate successfully generated."
  else
    echo "$SETUPSTR SSL Certificate generation failed. See '"$MOINLOG"' for details."
  fi

else
  echo "$SETUPSTR Existing SSL Certificates found, skip generation of new self-signed Certificates."
fi


#
# Adjust nginx server name
#
if [ "$FQDN" != "$DEFAULT_FQDN" ]; then
  grep -q $DEFAULT_FQDN $NGINXCFG
  RC=$?

  if [ "$RC" = "0" ]; then
    sed -i "s/$DEFAULT_FQDN/$FQDN/g" $NGINXCFG
    grep -q $FQDN $NGINXCFG
    RC=$?

    if [ "$RC" = "0" ]; then
      echo "$SETUPSTR '"$DEFAULT_FQDN"' successfully replaced with '"$FQDN"' in nginx config"
    else
      echo "$SETUPSTR '"$DEFAULT_FQDN"' could not be replaced with '"$MAUSR"' in nginx config. Check '"$NGINXCFG"'."
    fi
  else
    echo "$SETUPSTR Custom FQDN already part of the nginx configuration, nothing to do."
  fi

else
  echo "$SETUPSTR No custom FQDN defined, skip nginx reconfiguration."
fi


#
# Cleanup
#
rm -rf /tmp/*


#
# Re-Configure stdout / stderr to nginx logs
#
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log
