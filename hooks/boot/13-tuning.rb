if has_custom_fact?('tuning')
  # TODO: automatically get the tuning sizes - standard doesn't exist and only
  # loads base. The rest maps to config/foreman.hiera/tuning/sizes/$size.yaml
  TUNING_SIZES = ['default'] + ['medium', 'large', 'extra-large', 'extra-extra-large']
  TUNING_FACT = 'tuning'.freeze

  app_option(
    '--tuning',
    'INSTALLATION_SIZE',
    "Tune for an installation size. Choices: #{TUNING_SIZES.join(', ')}",
    :default => get_custom_fact(TUNING_FACT)
  ) do |value|
    unless TUNING_SIZES.include?(value)
      signal_usage_error("Invalid option supplied for --tuning. Please choose from one of: #{TUNING_SIZES.join(', ')}")
    end

    value
  end
end
