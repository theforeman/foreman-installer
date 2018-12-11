require 'fileutils'

STEP_DIRECTORY = '/etc/foreman-installer/applied_hooks/pre/'
SSL_BUILD_DIR = param('certs', 'ssl_build_dir').value
MONGO_ENGINE_MMAPV1 = '/etc/foreman-installer/.mongo_engine_mmapv1'.freeze

def stop_services
  Kafo::Helpers.execute('katello-service stop')
end

def start_postgresql
  Kafo::Helpers.execute('katello-service start --only postgresql')
end

def migrate_candlepin
  db_host = param('katello', 'candlepin_db_host').value
  db_port = param('katello', 'candlepin_db_port').value
  db_name = param('katello', 'candlepin_db_name').value
  db_user = param('katello', 'candlepin_db_user').value
  db_password = param('katello', 'candlepin_db_password').value
  db_ssl = param('katello', 'candlepin_db_ssl').value
  db_ssl_verify = param('katello', 'candlepin_db_ssl_verify').value
  db_uri = "//#{db_host}" + (db_port.nil? ? '' : ":#{db_port}") + "/#{db_name}"
  if db_ssl
    db_uri += "?ssl=true"
    db_uri += "&sslfactory=org.postgresql.ssl.NonValidatingFactory" unless db_ssl_verify
  end
  Kafo::Helpers.execute("/usr/share/candlepin/cpdb --update --database '#{db_uri}' --user '#{db_user}' --password '#{db_password}'")
end

def migrate_pulp
  # Start mongo
  if `rpm -q mongodb --queryformat=%{version}`.start_with?('2.') # If mongo 2.x is on the system run the migration with that.
    Kafo::Helpers.execute('systemctl start mongod')
  else
    Kafo::Helpers.execute('systemctl start rh-mongodb34-mongod')
  end

  Kafo::Helpers.execute('su - apache -s /bin/bash -c pulp-manage-db')
end

def migrate_foreman
  Kafo::Helpers.execute('foreman-rake db:migrate')
end

def mongo_mmapv1_check
  custom_hiera = '/etc/foreman-installer/custom-hiera.yaml'
  mongodb_dir = '/var/lib/mongodb/'
  # check and see if we have a pulp_database already from MMAPv1.
  if File.file?("#{mongodb_dir}/pulp_database.0")
    # check if we have modifed the custom_hiera file or if there is a WiredTiger file in the db directory.
    if File.foreach("#{custom_hiera}").grep(/mongodb::server::storage_engine:/).any? || File.file?("#{mongodb_dir}/WiredTiger.wt")
      logger.info 'No changed needed, Mongo storage engine will installed/kept with WiredTiger'
    else
      # Stop Mongo 2.x
      Kafo::Helpers.execute('systemctl stop mongod')
      # set storage engine to MMAPv1 in Hiera file and create engine file.
      logger.info 'Detecting Pulp database and no WiredTiger files, keeping storage engine as MMAPv1'
      logger.info 'To upgrade to WiredTiger at a later time run foreman-installer with the --upgrade-mongo-storage flag.'
      # Write to custom_hiera to tell users to not touch the setting.
      open(custom_hiera, 'a') do |f|
        f << "# Added by foreman-installer during upgrade, run the installer with --upgrade-mongo-storage to upgrade to WiredTiger.\n"
        f << "mongodb::server::storage_engine: 'mmapv1'\n"
      end

      # Create engine file so we know Mongo is in mmapv1 for engine upgrade hook.
      File.open(MONGO_ENGINE_MMAPV1, 'w') do |file|
        file.write("Mongo storage engine set to mmapv1 on #{Time.now}")
      end
    end
  else
    logger.debug 'No changed needed, Mongo storage engine will installed/kept with WiredTiger.'
  end
end

def remove_legacy_mongo
  # Check to see if the RPMS exist and if so remove them and create the upgrade done file, and install rh-mongodb34-mongodb-syspaths.

  if `rpm -q mongodb --queryformat=%{version}`.start_with?('2.')
    logger.warn 'removing MongoDB 2.x packages, config and log files.'
    Kafo::Helpers.execute('yum remove -y mongodb-2* mongodb-server-2* > /dev/null 2>&1')
    File.unlink('/etc/mongod.conf') if File.exist?('/etc/mongod.conf')
  else
    logger.info 'MongoDB 2.x not detected, skipping'
  end
end

def mark_qpid_cert_for_update
  hostname = param('certs', 'node_fqdn').value

  all_cert_names = Dir.glob(File.join(SSL_BUILD_DIR, hostname, '*.noarch.rpm')).map do |rpm|
    File.basename(rpm).sub(/-1\.0-\d+\.noarch\.rpm/, '')
  end.uniq

  if (qpid_cert = all_cert_names.find { |cert| cert =~ /-qpid-broker$/ })
    path = File.join(*[SSL_BUILD_DIR, hostname, qpid_cert].compact)
    Kafo::Helpers.log_and_say :info, "Marking certificate #{path} for update"
    FileUtils.touch("#{path}.update")
  else
    Kafo::Helpers.log_and_say :debug, "No existing broker cert found; skipping update"
  end
end

# rubocop:disable Style/MultipleComparison
def upgrade_qpid_paths
  qpid_dir = '/var/lib/qpidd'
  qpid_data_dir = "#{qpid_dir}/.qpidd"

  qpid_linearstore = "#{qpid_data_dir}/qls"
  if Dir.glob("#{qpid_linearstore}/jrnl/**/*.jrnl").empty? && !File.exist?("#{qpid_linearstore}/dat")
    logger.info 'Qpid directory upgrade is already complete, skipping'
  else
    backup_file = "/var/cache/qpid_queue_backup.tar.gz"

    unless File.exist?(backup_file)
      # Backup data directory before upgrade
      puts "Backing up #{qpid_dir} in case of migration failure"
      Kafo::Helpers.execute("tar -czf #{backup_file} #{qpid_dir}")
    end

    # Make new directory structure for migration
    Kafo::Helpers.execute("mkdir -p #{qpid_linearstore}/p001/efp/2048k/in_use")
    Kafo::Helpers.execute("mkdir -p #{qpid_linearstore}/p001/efp/2048k/returned")
    Kafo::Helpers.execute("mkdir -p #{qpid_linearstore}/jrnl2")

    if File.exist?("#{qpid_linearstore}/dat") && File.exist?("#{qpid_linearstore}/dat2")
      Kafo::Helpers.execute("rm -rf #{qpid_linearstore}/dat2")
    end

    if File.exist?("#{qpid_linearstore}/dat") && !File.exist?("#{qpid_linearstore}/dat2}")
      # Move dat directory to new location dat2
      Kafo::Helpers.execute("mv #{qpid_linearstore}/dat #{qpid_linearstore}/dat2")
    end

    # Move qpid jrnl files
    Dir.foreach("#{qpid_linearstore}/jrnl") do |queue_name|
      next if queue_name == '.' || queue_name == '..'
      next unless File.directory?("#{qpid_linearstore}/jrnl/#{queue_name}")

      puts "Moving #{queue_name}"
      Kafo::Helpers.execute("mkdir -p #{qpid_linearstore}/jrnl2/#{queue_name}/")
      Dir.foreach("#{qpid_linearstore}/jrnl/#{queue_name}") do |jrnlfile|
        next if jrnlfile == '.' || jrnlfile == '..'

        Kafo::Helpers.execute("mv #{qpid_linearstore}/jrnl/#{queue_name}/#{jrnlfile} #{qpid_linearstore}/p001/efp/2048k/in_use/#{jrnlfile}")
        Kafo::Helpers.execute("ln -s #{qpid_linearstore}/p001/efp/2048k/in_use/#{jrnlfile} #{qpid_linearstore}/jrnl2/#{queue_name}/#{jrnlfile}")
        unless $?.success?
          logger.error "There was an error during the migration, exiting. A backup of the #{qpid_dir} is at /var/cache/qpid_queue_backup.tar.gz"
          kafo.class.exit(1)
        end
      end
    end

    # Restore access
    Kafo::Helpers.execute("chown -R qpidd:qpidd #{qpid_dir}")

    # restore SELinux context by current policy
    Kafo::Helpers.execute("restorecon -FvvR #{qpid_dir}")
    logger.info 'Qpid path upgrade complete'
    Kafo::Helpers.execute("rm -f #{backup_file}")
    logger.info 'Removing old jrnl directory'
    Kafo::Helpers.execute("rm -rf #{qpid_linearstore}/jrnl")
  end
end

def drop_apache_foreman_group
  Kafo::Helpers.execute("gpasswd -d apache foreman")
end

def upgrade_step(step, options = {})
  noop = app_value(:noop) ? ' (noop)' : ''
  long_running = options[:long_running] ? ' (this may take a while) ' : ''
  run_always = options.fetch(:run_always, false)

  if run_always || app_value(:force_upgrade_steps) || !step_ran?(step)
    Kafo::Helpers.log_and_say :info, "Upgrade Step: #{step}#{long_running}#{noop}..."
    unless app_value(:noop)
      status = send(step)
      fail_and_exit "Upgrade step #{step} failed. Check logs for more information." unless status
      touch_step(step)
    end
  end
end

def touch_step(step)
  FileUtils.mkpath(STEP_DIRECTORY) unless Dir.exists?(STEP_DIRECTORY)
  FileUtils.touch(step_path(step))
end

def step_ran?(step)
  File.exists?(step_path(step))
end

def step_path(step)
  File.join(STEP_DIRECTORY, step.to_s)
end

def fail_and_exit(message)
  Kafo::Helpers.log_and_say :error, message
  kafo.class.exit 1
end

if app_value(:upgrade)
  Kafo::Helpers.log_and_say :info, 'Upgrading, to monitor the progress on all related services, please do:'
  Kafo::Helpers.log_and_say :info, '  foreman-tail | tee upgrade-$(date +%Y-%m-%d-%H%M).log'
  sleep 3

  katello = Kafo::Helpers.module_enabled?(@kafo, 'katello')
  foreman_proxy_content = @kafo.param('foreman_proxy_plugin_pulp', 'pulpnode_enabled').value

  upgrade_step :stop_services, :run_always => true

  if katello
    upgrade_step :start_postgresql, :run_always => true
  end

  if katello || foreman_proxy_content
    upgrade_step :upgrade_qpid_paths
    upgrade_step :migrate_pulp, :run_always => true
  end

  if foreman_proxy_content
    upgrade_step :mongo_mmapv1_check
    upgrade_step :remove_legacy_mongo
  end

  if katello
    upgrade_step :mark_qpid_cert_for_update
    upgrade_step :migrate_candlepin, :run_always => true
    upgrade_step :migrate_foreman, :run_always => true
    upgrade_step :mongo_mmapv1_check
    upgrade_step :remove_legacy_mongo
    upgrade_step :drop_apache_foreman_group
  end

  Kafo::Helpers.log_and_say :info, 'Upgrade Step: Running installer...'
end
