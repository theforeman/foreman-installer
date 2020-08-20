HIERA_FILE = '/etc/foreman-installer/custom-hiera.yaml'.freeze
SCL_POSTGRESQL_CONF = '/var/opt/rh/rh-postgresql12/lib/pgsql/data/postgresql.conf'.freeze

custom_hiera = YAML.load_file(HIERA_FILE)

if custom_hiera &&
   custom_hiera.key?('postgresql::server::config_entries') &&
   custom_hiera['postgresql::server::config_entries'].key?('checkpoint_segments')

  message = <<~HEREDOC
  ERROR:
    checkpoint_segments tuning found in #{HIERA_FILE}
    This tuning option is no longer valid in PostgreSQL 9.5+
    Please remove this from the following locations and then re-run the installer:
      - #{HIERA_FILE}
  HEREDOC

  if File.exist?(SCL_POSTGRESQL_CONF)
    message += "    - #{SCL_POSTGRESQL_CONF}"
  end

  if katello_present?
    message += <<~HEREDOC

      The presence of checkpoint_segments in #{HIERA_FILE} indicates manual tuning.
      Manual tuning can override values provided by the --tuning parameter.
      Review #{HIERA_FILE} for values that are already provided by the built in tuning profiles.
      Built in tuning profiles also provide a supported upgrade path.
    HEREDOC
  end

  fail_and_exit(message)
end
