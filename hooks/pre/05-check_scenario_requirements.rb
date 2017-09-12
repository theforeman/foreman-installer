require 'pathname'

PREFIX = %W(PiB TiB GiB MiB KiB B).freeze

# From https://codereview.stackexchange.com/questions/9107/printing-human-readable-number-of-bytes
def as_size(s)
  s = s.to_f
  i = PREFIX.length - 1
  while s > 512 && i > 0
    i -= 1
    s /= 1024
  end
  ((s > 9 || s.modulo(1) < 0.1 ? '%d' : '%.1f') % s) + ' ' + PREFIX[i]
end

def available_space(directory)
  mountpoints = facts[:mountpoints]
  until (mountpoint = mountpoints[directory.to_sym])
    directory = File.dirname(directory)
  end
  mountpoint[:available_bytes]
end

def scenario_requirements
  scenario_data[:required] || {}
end

def ram
  facts[:memory][:system][:total_bytes]
end

def cores
  facts[:processors][:count]
end

def check
  requirements = scenario_requirements

  if requirements.nil? || requirements.empty?
    logger.debug 'No requirements for this scenario'
    return
  end

  if facts.empty?
    raise Exception, 'Failed to load facts'
  end

  if (min_ram = requirements['memory']) && ram < (min_ram * 0.9)
    raise Exception, "This system has #{as_size(ram)} of total memory. Please ensure at least #{as_size(min_ram)} of total memory before running the installer."
  end

  if (min_cores = requirements['cores']) && cores < min_cores
    raise Exception, "This system has #{cores} CPU cores. Please ensure at least #{min_cores} cores before running the installer."
  end

  if directories = requirements['directories']
    (directories['minimum'] || {}).each do |directory, min_available|
      available = available_space(directory)

      if available < min_available
        raise Exception, "Please ensure directory #{directory} has at least #{as_size(min_available)} available."
      end
    end
  end
end

if app_value(:disable_system_checks)
  logger.warn 'Skipping system checks.'
else
  begin
    check
  rescue Exception => e
    logger.error e.message
    exit(1)
  end
end
