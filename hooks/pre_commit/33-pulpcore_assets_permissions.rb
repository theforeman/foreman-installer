# hooks/pre/33-pulpcore_assets_permissions.rb needs user pulp
DIRECTORY = '/var/lib/pulp/assets'.freeze
USER = 'pulp'.freeze
if File.directory?(DIRECTORY)
  require 'etc'

  begin
    Etc.getpwnam(USER)
  rescue ArgumentError
    fail_and_exit("Detected incorrect permissions on #{DIRECTORY} but user #{USER} doesn't exist")
  end
end
