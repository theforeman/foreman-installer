require 'fileutils'
def fail_and_exit(message)
  Kafo::Helpers.log_and_say :error, message
  kafo.class.exit 1
end

def migration
  katello = Kafo::Helpers.module_enabled?(@kafo, 'katello')
  export_dir = '/var/tmp/mongodb_engine_upgrade'
  mongo_dir = '/var/lib/mongodb'
  hiera_file = '/etc/foreman-installer/custom-hiera.yaml'
  mongodb_backup = '/var/tmp/mongodb_backup'
  mongo_conf = '/etc/opt/rh/rh-mongodb34/mongod.conf'
  pulp_db_param = param('katello', 'pulp_db_name')

  # Create export directory and dump MongoDB
  logger.info 'Stopping Pulp services except MongoDB'
  Kafo::Helpers.execute('foreman-maintain service stop --exclude "rh-mongodb34-mongod","postgresql","tomcat","dynflowd","foreman-proxy","puppetserver"')
  FileUtils.mkdir(export_dir)
  File.chmod(0700, export_dir)
  logger.info "Starting mongodump to #{export_dir}"
  Kafo::Helpers.execute("mongodump --host localhost --out #{export_dir}")

  # Move datafiles out of MongoDB directory so it will start
  logger.info 'Export done, stopping MongoDB to move old datafiles'
  Kafo::Helpers.execute('foreman-maintain service stop --only rh-mongodb34-mongod')
  logger.info "Moving contents from #{mongo_dir} to #{mongodb_backup}"
  FileUtils.mkdir_p(mongodb_backup)
  File.chmod(0700, mongodb_backup)
  Kafo::Helpers.execute("mv #{mongo_dir}/* #{mongodb_backup}")

  # Import the dump, fail and notify user of backup if restore does not work.
  logger.info 'Changing config to WiredTiger and starting restore.'
  Kafo::Helpers.execute("sed -i.bak -e 's/mmapv1/wiredTiger/g' #{mongo_conf}")
  Kafo::Helpers.execute("mv #{mongo_conf}.bak #{mongodb_backup}")
  Kafo::Helpers.execute('foreman-maintain service start --only rh-mongodb34-mongod')
  pulp_db = katello ? param('katello', 'pulp_db_name').value : 'pulp_database'
  Kafo::Helpers.execute("mongorestore --host localhost --db=#{pulp_db} --drop --quiet --dir=#{export_dir}/#{pulp_db}")
  unless $?.success?
    logger.error 'The restore could not be completed correctly, reverting actions.'
    logger.info 'Stopping MongoDB'
    Kafo::Helpers.execute('foreman-maintain service stop --only rh-mongodb34-mongod')
    logger.info 'Restoring old config'
    Kafo::Helpers.execute("mv -f #{mongodb_backup}/mongod.conf.bak #{mongo_conf}")
    logger.info "Removing contents in #{mongo_dir}"
    Kafo::Helpers.execute("rm -rf #{mongo_dir}/*")
    logger.info "Moving old content from #{mongodb_backup} to #{mongo_dir}"
    Kafo::Helpers.execute("mv #{mongodb_backup}/* #{mongo_dir}/")
    logger.info 'Starting MongoDB with old config and database files'
    Kafo::Helpers.execute('foreman-maintain service start --only rh-mongodb34-mongod')
    kafo.class.exit 1
  end

  # Remove old data files
  logger.info "Import done, removing old data in #{mongodb_backup}"
  Kafo::Helpers.execute("rm -rf #{mongodb_backup}")

  # Update Hiera to wiredTiger for installer run
  logger.info 'Changing custom Hiera to use wiredTiger for installer Puppet run.'
  Kafo::Helpers.execute("sed -i -e 's/Added by foreman-installer during upgrade, run the installer with --upgrade-mongo-storage to upgrade to WiredTiger./Do not remove'/g #{hiera_file}")
  Kafo::Helpers.execute("sed -i -e 's/mmapv1/wiredTiger/g' #{hiera_file}")
end

if app_value(:upgrade_mongo_storage_engine)
  migration
end
