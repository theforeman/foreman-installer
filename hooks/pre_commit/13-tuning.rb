if app_option?(:tuning)
  # A mapping of tuning profile to the required CPU cores and memory in GB
  TUNING_SIZES = {
    'default' => { cpu_cores: 1, memory: 8 },
    'medium' => { cpu_cores: 8, memory: 32 },
    'large' => { cpu_cores: 16, memory: 64 },
    'extra-large' => { cpu_cores: 32, memory: 128 },
    'extra-extra-large' => { cpu_cores: 48, memory: 256 },
  }.freeze
  TUNING_FACT = 'tuning'.freeze

  EXIT_INVALID_TUNING = 101
  EXIT_INSUFFICIENT_CPU_CORES = 102
  EXIT_INSUFFICIENT_MEMORY = 103

  current_tuning = get_custom_fact(TUNING_FACT)
  if module_enabled?('foreman')
    new_tuning = app_value(:tuning)
  else
    new_tuning = current_tuning
  end

  required = TUNING_SIZES[new_tuning]
  if required.nil?
    say "<%= color('Invalid tuning profile', :bad) %>"
    say "'#{new_tuning}' is not one of #{TUNING_SIZES.keys.join(', ')}"
    exit EXIT_INVALID_TUNING
  end

  unless app_value(:disable_system_checks)
    required_cores = required[:cpu_cores]
    required_memory = required[:memory]

    # Check if it's actually 90% of the required. If a crash kernel is enabled
    # then the reported total memory is lower than in reality.
    if facts[:memory][:system][:total_bytes] < (required_memory * 1024 * 1024 * 1024 * 0.9)
      if app_value(:tuning)
        say "<%= color('Insufficient memory for tuning size', :bad) %>"
        say "Tuning profile '#{new_tuning}' requires at least #{required_memory} GB of memory and #{required_cores} CPU cores"
      else
        say "The #{scenario_id} scenario requires at least #{required_memory} GB of memory and #{required_cores} CPU cores"
      end
      exit EXIT_INSUFFICIENT_MEMORY
    end

    if facts[:processors][:count] < required_cores
      if app_value(:tuning)
        say "<%= color('Insufficient CPU cores for tuning size', :bad) %>"
        say "Tuning profile '#{new_tuning}' requires at least #{required_memory} GB of memory and #{required_cores} CPU cores"
      else
        say "The #{scenario_id} scenario requires at least #{required_memory} GB of memory and #{required_cores} CPU cores"
      end
      exit EXIT_INSUFFICIENT_CPU_CORES
    end
  end

  if current_tuning != new_tuning
    store_custom_fact(TUNING_FACT, new_tuning)
    # Store the app config to disk
    kafo.config.configure_application
  end
end
