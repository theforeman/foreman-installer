# Contributing

## Filing and Fixing Issues

All issues are tracked using [Redmine](https://projects.theforeman.org/projects/puppet-foreman/issues). There are two types of issues that may arise:

  * A bug within an individual module
  * A bug within the hooks or scripts of the installer

### Module Bugs

For bugs found within an individual module, the following needs doing:

  * A bug should be filed under the "Foreman modules" or the "External modules" categories, depending on the module being owned by the Foreman or a third party (see the Puppetfile for a list of modules and their locations)
  * Fix and open a PR against the module itself
  * Once the fix is available within the module, follow the *Updating Packages* section and open a PR with the updates

### Installer Bugs

For bugs found within the hooks, config, answer or script files, please do the following:

  * Open a Redmine issues describing the problem
  * Fix and open a PR against the installer

## Updating Packages

This repository uses the gems librarian and librarian-puppet to handle the dependent
puppet modules.

```
gem install librarian librarian-puppet puppet
librarian-puppet update
```

## Releasing a new version

To release a new version:
  * pin module versions in Puppetfile
  * ensure puppet4 is installed on your system via yum/rpm
  * if you've got rvm installed: `rvm use system`
  * run:
```
   bundle install
   rake pkg:generate_source
```
  * copy the generated source in ./pkg/ to fedorapeople.org:/project/katello/releases/source/tarball/
