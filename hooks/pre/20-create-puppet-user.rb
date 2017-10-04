# Workaround for http://projects.theforeman.org/issues/19986
# Puppet behaves unexpected if the puppet user does not exist. With puppet 3
# the puppet user was created in the agent package but now it's only done by
# the server package.
#
# The result is that puppet thinks the service user is root and sets the
# owner/group of hostcrl to that. It happens after the puppetserver is started,
# but causes it to refuse to restart.

require 'etc'

if module_enabled?('puppet') && param('puppet', 'server').value != false && !app_value(:noop)
  if File.exists?('/etc/redhat-release')
    uid = '-u 52'
    gid = '-g 52'
  else
    uid = gid = ''
  end

  begin
    Etc.getgrnam('puppet')
  rescue ArgumentError
    %x{groupadd -r puppet #{gid}}
  end

  begin
    Etc.getpwnam('puppet')
  rescue ArgumentError
    # These are the defaults on CentOS 7 with Puppet 4 but we can assume that
    # puppet 3 already created the user so we never reach this code.
    comment = 'puppetserver daemon'
    homedir = '/opt/puppetlabs/server/data/puppetserver'
    %x{useradd -r #{uid} puppet -d "#{homedir}" -s /sbin/nologin -c "#{comment}" puppet}
  end
end
