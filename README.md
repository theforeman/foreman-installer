# Puppet modules for managing Foreman

Installs Foreman as a standalone application or using apache passenger.

Installs Foreman Proxy

May install an example puppet master setup using passenger as well, including the tweaks required for foreman.


# Installation

## Stable release

Releases of foreman-installer are made via RPM and deb packages and are
published via the normal Foreman repositories.

See the manual and quickstart guide available at [theforeman.org](http://theforeman.org/).

## Using GIT

git clone https://github.com/theforeman/foreman-installer.git

Using the git version for develop or testing requires the puppet-agent AIO package be available. Follow the instructions for your OS from [Puppet](https://puppet.com/docs/puppet/latest/install_linux.html). Additionally, after installing puppet-agent the puppet-strings gem needs to be available in the environment:

```
/opt/puppetlabs/puppet/bin/gem install puppet-strings
```

# Requirements

if you are using RHEL, EPEL repo must be enabled <http://fedoraproject.org/wiki/EPEL>

if you are using Debian (or Ubuntu), see the additional notes in README.debian

The Puppet Labs repositories may optionally be enabled for newer versions of Puppet
than are available in base OS repos.

# Setup

Please review the "answers" or setup file: /etc/foreman-installer/scenarios.d/foreman-answers.yaml. This file allows
you to override any of the default parameters (as specified in <module>/manifests/params.pp)

Once you are fine with your answer file, install it with this command:

    foreman-installer

or if you prefer interactive mode

    foreman-installer -i


The answer file is a yaml format. For a module just using the defaults, simply put
"modulename: true" to include, or false to exclude. For a module which you wish to
override any defaults, it becomes a hash, with each overridden parameter as a key-value
pair.

A few sample files now follow:

All-in-one installation:

    ---
    foreman: true
    puppet:
      server: true
    foreman_proxy: true

Just Foreman on its own:

    ---
    foreman: true
    puppet: false
    foreman_proxy: false

Foreman and Foreman-Proxy:

    ---
    foreman: true
    puppet: false
    foreman_proxy: true

Puppetmaster with Git and Proxy:

    ---
    foreman: false
    puppet:
      server: true
      server_git_repo: true
    foreman_proxy: true

Foreman & proxy with a different username:

    ---
    foreman:
      user: 'myforeman'
    puppet: false
    foreman_proxy:
      user: 'myproxy'

Extras
------

If you just want to include the relavant bits to run on your puppet master you may

    include foreman::params, foreman::config::enc, foreman::config::reports

# Contributing

* Fork the project
* Commit and push until you are happy with your contribution
* Send a pull request with a description of your changes

See [CONTRIBUTING.md](/CONTRIBUTING.md) for more details.

# Katello

This repository also contains the tooling required to install Foreman Katello.

See [KATELLO.md](/KATELLO.md) for details and specifics of that setup.

# More info

See http://theforeman.org or at #theforeman irc channel on freenode

Copyright (c) 2010-2012 Ohad Levy and their respective owners

Except where specified in provided modules, this program and entire
repository is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
