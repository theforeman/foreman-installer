# https://github.com/theforeman/puppet-foreman/commit/e0fc1487740d36a5a308498576836525d3e52de1
# The value db_database is no longer optional
if answers['foreman'].is_a?(Hash) && answers['foreman']['db_database'].nil?
  answers['foreman'].delete('db_database')
end
