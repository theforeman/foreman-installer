require 'pathname'

PULP_ROOT = Pathname.new('/var/lib/pulp')
LEGACY_DIR = PULP_ROOT / 'docroot'
DESTINATION = PULP_ROOT / 'media'

if LEGACY_DIR.directory? && !LEGACY_DIR.symlink?
  logger.debug("Migrating #{LEGACY_DIR} to #{DESTINATION}")
  unless app_value(:noop)
    LEGACY_DIR.rename(DESTINATION)
    LEGACY_DIR.make_symlink(DESTINATION)
  end
end
