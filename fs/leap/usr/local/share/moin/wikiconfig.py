# -*- coding: iso-8859-1 -*-
#
# SPDX-FileCopyrightText: 2018 MoinMoin:ThomasWaldmann
# SPDX-FileCopyrightText: 2021 Dominik Wombacher <dominik@wombacher.cc>
# SPDX-License-Identifier: GPL-2.0-or-later
#
"""
    MoinMoin - Configuration
    Further reading: http://moinmo.in/HelpOnConfiguration
"""

import os

from MoinMoin.config import multiconfig, url_prefix_static


class Config(multiconfig.DefaultConfig):
    wikiconfig_dir = os.path.abspath(os.path.dirname(__file__))
    instance_dir = wikiconfig_dir
    data_dir = os.path.join(instance_dir, 'data', '') # path with trailing /
    data_underlay_dir = os.path.join(instance_dir, 'underlay', '') # path with trailing /
    sitename = u'Untitled Wiki'
    logo_string = u'<img src="%s/common/moinmoin.png" alt="MoinMoin Logo">' % url_prefix_static
    page_front_page = u"FrontPage"
    superuser = [u"MoinAdmin", ]
    acl_rights_before = u"MoinAdmin:read,write,delete,revert,admin"
    acl_rights_default = u"Trusted:read,write,delete,revert Known:read All:read"
    from MoinMoin.security.antispam import SecurityPolicy

    # Mail --------------------------------------------------------------
    # Configure to enable subscribing to pages (disabled by default)
    # or sending forgotten passwords.
    # SMTP server, e.g. "mail.provider.com" (None to disable mail)
    #mail_smarthost = ""
    # The return address, e.g u"J�rgen Wiki <noreply@mywiki.org>" [Unicode]
    #mail_from = u""
    # "user pwd" if you need to use SMTP AUTH
    #mail_login = ""

    navi_bar = [
        # If you want to show your page_front_page here:
        u'%(page_front_page)s',
        u'RecentChanges',
        u'FindPage',
        u'HelpContents',
    ]
    theme_default = 'modernized'
    language_default = 'en'
    page_category_regex = ur'(?P<all>Category(?P<key>(?!Template)\S+))'
    page_dict_regex = ur'(?P<all>(?P<key>\S+)Dict)'
    page_group_regex = ur'(?P<all>(?P<key>\S+)Group)'
    page_template_regex = ur'(?P<all>(?P<key>\S+)Template)'
    show_hosts = 1
    page_credits = [
        '<a href="https://moinmo.in/" title="This site uses the MoinMoin Wiki software.">MoinMoin Powered</a>',
        '<a href="https://moinmo.in/Python" title="MoinMoin is written in Python.">Python Powered</a>',
        '<a href="https://pypy.org" title="MoinMoin is running on PyPy.">PyPy Powered</a>',
        '<a href="https://moinmo.in/GPL" title="MoinMoin is GPL licensed.">GPL licensed</a>',
        ]
    backup_include = ['/usr/local/share/moin/']
    backup_users = ['MoinAdmin']
