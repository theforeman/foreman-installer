require 'pathname'

PULP_ROOT = Pathname.new('/var/lib/pulp')
LEGACY_DIR = PULP_ROOT / 'artifact'
NEW_MEDIA_ROOT = PULP_ROOT / 'media'
DESTINATION = NEW_MEDIA_ROOT / LEGACY_DIR.basename

if LEGACY_DIR.directory? && !LEGACY_DIR.symlink?
  logger.debug("Migrating #{LEGACY_DIR} to #{DESTINATION}")
  unless app_value(:noop)
    NEW_MEDIA_ROOT.mkpath
    LEGACY_DIR.rename(DESTINATION)
    LEGACY_DIR.make_symlink(DESTINATION)
  end
end
