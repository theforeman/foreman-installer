# puppet-candlepin uses this file to know whether it needs to run cpdb --update
CANDLEPIN_MIGRATION_MARKER_FILE = '/var/lib/candlepin/cpdb_update_done'.freeze

if File.exist?(CANDLEPIN_MIGRATION_MARKER_FILE)
  File.unlink(CANDLEPIN_MIGRATION_MARKER_FILE)
end
