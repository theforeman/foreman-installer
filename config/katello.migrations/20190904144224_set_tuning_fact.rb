scenario[:facts] = {} unless scenario.key?(:facts)
scenario[:facts]['tuning'] ||= 'default'
