MONGO_DIR = '/var/lib/mongodb/'

def fail_and_exit(message)
  Kafo::Helpers.log_and_say :error, message
  kafo.class.exit 1
end

def disk_space
  # Check diskspace in /var/tmp
  logger.info 'Checking available diskspace in /var/tmp for upgrade'
  total_space = `df -k --output=avail /var/tmp`.split("\n").last.to_i
  mongo_size = File.directory?(MONGO_DIR) ? `du -s  #{@MONGO_DIR}`.split[0].to_i : 0
  if total_space < mongo_size
    fail_and_exit "There is not enough free space #{total_space}, the size of MongoDB database is #{mongo_size}, please add additional space to /var/tmp and try again, exiting."
  else
    logger.debug "There is #{total_space} free space on disk, which is more than the size of the MongoDB database of #{mongo_size}, continuing with upgrade"
  end
end

if app_value(:upgrade_mongo_storage_engine)
  # Fail if MongoDB is already running in wiredTiger.
  if File.file?("#{MONGO_DIR}/WiredTiger.wt")
    fail_and_exit 'MongoDB has already been switched to wiredTiger. Exiting.'
  end
  if app_value(:upgrade)
    fail_and_exit 'Concurrent use of --upgrade and --upgrade-mongo-storage-engine is not supported. '\
                  'Please run --upgrade first, then --upgrade-mongo-storage-engine.'
  end

  # Fail if we are not using the Katello/Foreman Proxy Content scenario.
  katello = Kafo::Helpers.module_enabled?(@kafo, 'katello')
  foreman_proxy_content = Kafo::Helpers.module_enabled?(@kafo, 'foreman_proxy_content')
  fail_and_exit 'MongoDB storage engine upgrade is not currently supported for the chosen scenario.' unless katello || foreman_proxy_content

  # Fail if Katello MongoDB is not localhost, does not have a valid db connection, or an invalid value in the answerfile.
  if katello
    pulp_host_param = param('katello', 'pulp_db_seeds')
    fail_and_exit('No value set for MongoDB connection') unless pulp_host_param
    mongo_host = pulp_host_param.value
    fail_and_exit 'Upgrading is not supported on remote MongoDB database connections' unless mongo_host == 'localhost:27017'
  end

  Kafo::Helpers.log_and_say :info, "Starting disk space check for upgrade"
  disk_space
end

if app_value(:disable_system_checks)
  logger.warn 'Skipping system checks.'
end
