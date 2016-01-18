LEGACY_CONF_DIR = '/etc/foreman'
LEGACY_CONFIG_NAME = 'foreman-installer.yaml'
SCENARIO_NAME = 'foreman.yaml'
legacy_config_file = File.join(LEGACY_CONF_DIR, LEGACY_CONFIG_NAME)

if File.exists?(legacy_config_file)
  legacy_config = Kafo::Configuration.new(legacy_config_file)
  logger.info("Legacy configuration was found in #{legacy_config_file}")

  # do not migrate config that was never used
  if legacy_config.log_exists?
    scenario_file = File.join(kafo.class.scenario_manager.config_dir, SCENARIO_NAME)
    scenario = Kafo::Configuration.new(scenario_file)

    # copy over config and answers
    scenario.migrate_configuration(legacy_config)
    scenario.store(legacy_config.answers)

    # link last used scenario
    kafo.class.scenario_manager.link_last_scenario(scenario.config_file)
    logger.info("Scenario #{scenario.config_file} was detected to be the last used scenario")

    kafo.request_config_reload
    logger.info("Configuration #{legacy_config_file} was successfully migrated. Installer configuration reload was requested.")
  end

  # rename legacy config and answer file
  backup_config = legacy_config.config_file + '.backup'
  backup_answers = legacy_config.answer_file + '.backup'
  File.rename(legacy_config.answer_file, backup_answers)
  File.rename(legacy_config.config_file, backup_config)
  logger.info("Backup of legacy configuration was stored in #{backup_config} and #{backup_answers}.")
  legacy_config = nil
end
