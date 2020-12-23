require 'pathname'

PULP_ROOT = Pathname.new('/var/lib/pulp')
LEGACY_DIR = PULP_ROOT / 'docroot'
DESTINATION = PULP_ROOT / 'media'

if LEGACY_DIR.directory? && !LEGACY_DIR.symlink? && DESTINATION.directory?
  message = <<~MESSAGE
  Target #{DESTINATION} already exists. Unable to migrate Pulp media root from #{LEGACY_DIR}.

  Ensure #{LEGACY_DIR} is not a directory or #{DESTINATION} does not exist.
  MESSAGE
  fail_and_exit(message)
end
