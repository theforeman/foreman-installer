require 'facter'
require 'json'

# Check OS support for top-level modules and disable those that aren't known
# to work on the current OS.
def apply_os_support
  kafo.config.modules.each do |mod|
    metajson = File.join(KafoConfigure.modules_dir, mod.dir_name, 'foreman-installer.json')
    next unless File.exist?(metajson)

    meta = JSON.load(File.read(metajson))
    if meta[mod.identifier] && meta[mod.identifier]['operatingsystem_support']
      supported = meta[mod.identifier]['operatingsystem_support'].any? do |os|
        os.all? { |fname,fvalue| os_fact_matches?(fname, fvalue) }
      end

      unless supported
        logger.warn("Skipping module #{mod.name} as it isn't supported on this operating system. Please check the plugin documentation for its supported OSes, or use --ignore-os-support to attempt to run this module.")
        mod.disable
      end
    end
  end
end

def os_fact_matches?(name, value)
  os_value = [os_fact(name)].flatten.map(&:to_s)
  [value].flatten.any? do |value|
    os_value.include? value.to_s
  end
end

def os_fact(name)
  # metadata style uses osrelease when it really means the major release
  if name == 'operatingsystemrelease'
    maj = Facter.value(:operatingsystemmajrelease)
    return maj if maj

    # Facter 1.6 compatibility, no osmajrelease
    release = Facter.value(:operatingsystemrelease)
    [release, release.gsub(/\.[^\.]+\z/, '')]
  else
    Facter.value(name.to_sym)
  end
end

apply_os_support unless app_value(:ignore_os_support)
