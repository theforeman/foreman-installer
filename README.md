# Puppet modules for managing Foreman

Installs Foreman as a standalone application or using apache passenger.

Installs Foreman Proxy

May install an example puppet master setup using passenger as well, including the tweaks required for foreman.


# Installation

## Using GIT

git clone --recursive git://github.com/theforeman/foreman-installer.git

## Direct download

Since we are no longer using one repository for all sources, a single tarball is no longer provided.
Download the source code for each module on its own:

  * http://github.com/theforeman/puppet-apache/tarball/master
  * http://github.com/theforeman/puppet-foreman/tarball/master
  * http://github.com/theforeman/puppet-foreman_proxy/tarball/master
  * http://github.com/theforeman/puppet-passenger/tarball/master
  * http://github.com/theforeman/puppet-puppet/tarball/master
  * http://github.com/theforeman/puppet-tftp/tarball/master
  * http://github.com/theforeman/puppet-xinetd/tarball/master


# Requirements

if you are using RHEL, EPEL repo must be enabled <http://fedoraproject.org/wiki/EPEL>

if you are using Debian (or Ubuntu), see the additional notes in README.debian

# Setup

Please review the variables under module/manifests/params.pp

Standalone installation:

to install foreman:

    echo include foreman | puppet apply --modulepath /path_to/extracted_tarball

to install both foreman and its proxy:

    echo include foreman, foreman_proxy | puppet apply --modulepath /path_to/extracted_tarball

if you just want to include the relavant bits to run on your puppet master you may

    include foreman::params, foreman::config::enc, foreman::config::reports

if you want to install it all on one box

    export MODULE_PATH="/etc/puppet/modules/common"
    mkdir -p $MODULE_PATH
    for mod in apache foreman foreman_proxy passenger puppet tftp xinetd; do
      mkdir -p $MODULE_PATH/$mod
      wget http://github.com/theforeman/puppet-$mod/tarball/master -O - | tar xzvf - -C $MODULE_PATH/$mod --strip-components=1
    done;
    echo include puppet, puppet::server, foreman, foreman_proxy | puppet apply --modulepath $MODULE_PATH

# Contributing

* Fork the project
* Commit and push until you are happy with your contribution

# More info

See http://theforeman.org or at #theforeman irc channel on freenode

Copyright (c) 2010-2012 Ohad Levy

This program and entire repository is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
