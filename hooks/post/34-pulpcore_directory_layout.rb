require 'pathname'

LEGACY_DIR = Pathname.new('/var/lib/pulp/artifact')

if LEGACY_DIR.symlink?
  logger.debug("Removing legacy symlink #{LEGACY_DIR}")
  LEGACY_DIR.unlink unless app_value(:noop)
end
