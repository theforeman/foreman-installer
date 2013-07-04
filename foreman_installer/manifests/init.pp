# This class is called from the foreman install script (or Vagrantfile)
# and expects a yaml file to exist at either:
#   optional $answers class parameter
#   $modulepath/foreman_installer/answers.yaml
#   /etc/foreman_installer/answers.yaml
#
class foreman_installer(
  $answers = undef
) {

  if empty($::fqdn) {
    fail ("An FQDN is required for Foreman to install cleanly. Please ensure 'facter fqdn' returns the correct value before running this installer")
  }

  $params=loadanyyaml($answers,
                      "/etc/foreman-installer/answers.yaml",
                      "${settings::modulepath}/${module_name}/answers.yaml")

  foreman_installer::yaml_to_class { ['foreman', 'foreman_proxy', 'puppet']: }

  # Keep a more user-friendly name in the answers file
  foreman_installer::yaml_to_class { 'puppetmaster': classname => 'puppet::server' }

}
