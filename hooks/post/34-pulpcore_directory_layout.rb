require 'pathname'

LEGACY_DIR = Pathname.new('/var/lib/pulp/docroot')

if LEGACY_DIR.symlink?
  logger.debug("Removing legacy symlink #{LEGACY_DIR}")
  LEGACY_DIR.unlink unless app_value(:noop)
end
