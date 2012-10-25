# This class is called from the foreman install script (or Vagrantfile)
# and expects a yaml file to exist in either $modulepath/foreman-installer.yaml
# or /etc/foreman-installer.yaml
#
class foreman_installer {

  $params=loadyaml('/etc/foreman_installer/answers.yaml',
                  "${settings::modulepath}/foreman_installer/answers.yaml")

  foreman_installer::yaml_to_class { ['foreman', 'foreman_proxy', 'puppet']: }

  # Keep a more user-friendly name in the answers file
  foreman_installer::yaml_to_class { 'puppetmaster': classname => 'puppet::server' }

}
