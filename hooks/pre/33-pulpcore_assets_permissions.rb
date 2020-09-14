# Prior to Katello 3.18 assets were built by root. Katello 3.18 runs it as pulp
# and this corrects the permissions.
unless app_value(:noop)
  DIRECTORY = '/var/lib/pulp/assets'.freeze
  USER = 'pulp'.freeze

  if File.directory?(DIRECTORY) && File.stat(DIRECTORY).uid == 0
    require 'fileutils'
    FileUtils.chown_R(USER, USER, DIRECTORY)
  end
end
