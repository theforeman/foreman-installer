# Takes a key to lookup in the installation answers file
# - If it's a hash, declare a class with those parameters
# - If it's true or "true" declare the default parameters for that class
# - Otherwise ignore it
#
define foreman_installer::yaml_to_class (
  $classname = ''
) {

  if $classname == '' {
    $realname = $name
  } else {
    $realname = $classname
  }

  if is_hash($foreman_installer::params[$name]) {
    $params = { "${realname}" => $foreman_installer::params[$name] }
  } elsif $foreman_installer::params[$name] == true {
    $params = { "${realname}" => {} }
  }

  create_resources( 'class', $params )

}
