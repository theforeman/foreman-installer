require 'fileutils'

def clear_pulp_content
  content_dir = '/var/lib/pulp/content'
  if File.directory?(content_dir)
    stop_services

    logger.debug "Removing Pulp content inside '#{content_dir}'."
    FileUtils.rm_rf(Dir.glob(File.join(content_dir, '*')))
    logger.debug "Removed Pulp content inside '#{content_dir}', now resetting Pulp Repo importers."

    mongo_config = load_mongo_config
    start_services(['rh-mongodb34-mongod']) unless remote_host?(mongo_config[:host])
    reset_repo_importers(mongo_config)
    logger.info 'Pulp content successfully removed.'
  else
    logger.warn "Pulp content directory not present at '#{content_dir}'."
  end
end

def reset_repo_importers(config)
  if config[:ssl]
    ssl = '--ssl'
    if config[:ca_path]
      ca_cert = "--sslCAFile #{config[:ca_path]}"
      client_cert = "--sslPEMKeyFile #{config[:ssl_certfile]}" if config[:ssl_certfile]
    end
  end
  username = "-u #{config[:username]}" if config[:username]
  password = "-p #{config[:password]}" if config[:password]
  host = "--host #{config[:host]} --port #{config[:port]}"
  cmd_base = '--eval \'db.repo_importers.update({"scratchpad": {$ne: null}}, {$set: {"scratchpad.repomd_revision": null}}, {"multi":true})\''
  cmd = "mongo #{config[:database]} #{username} #{password} #{host} #{ssl} #{ca_cert} #{client_cert} #{cmd_base}"
  execute(cmd)
end

if app_value(:clear_pulp_content)
  if !pulp_enabled?
    logger.warn 'Skipping Pulp content reset because Pulp feature is disabled in scenario answers.'
  elsif app_value(:reset_data)
    logger.debug 'Skipping \'--clear-pulp-content\' because Pulp data and content will be reset with \'--reset-data\'.'
  elsif app_value(:noop)
    logger.warn 'Skipping Pulp data reset due to \'--noop\' flag.'
  else
    clear_pulp_content
  end
end
