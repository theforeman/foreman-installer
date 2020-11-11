require 'pathname'

PULP_ROOT = Pathname.new('/tmp/pulp')
LEGACY_DIR = PULP_ROOT / 'artifact'
NEW_MEDIA_ROOT = PULP_ROOT / 'media'
DESTINATION = NEW_MEDIA_ROOT / LEGACY_DIR.basename

pre_validations do
  if LEGACY_DIR.directory? && !LEGACY_DIR.symlink? && DESTINATION.directory?
    fail_and_exit("Target #{DESTINATION} already exists. Unable to migrate Pulp media root.")
  end
end

pre do
  if LEGACY_DIR.directory? && !LEGACY_DIR.symlink?
    logger.debug("Migrating #{LEGACY_DIR} to #{DESTINATION}")
    unless app_value(:noop)
      NEW_MEDIA_ROOT.mkpath
      LEGACY_DIR.rename(DESTINATION)
      LEGACY_DIR.make_symlink(DESTINATION)
    end
  end
end

post do
  if LEGACY_DIR.symlink?
    logger.debug("Removing legacy symlink #{LEGACY_DIR}")
    LEGACY_DIR.unlink unless app_value(:noop)
  end
end
