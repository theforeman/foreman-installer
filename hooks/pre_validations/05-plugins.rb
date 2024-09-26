if app_value(:list_plugins)

  class Plugin
    include Comparable

    attr_reader :group, :plugin, :provider, :module

    # We expect a mymod::plugin::myplugin structure but also allow
    # mymod::plugin::myplugin::provider
    def initialize(mod)
      parts = mod.identifier.split('::')

      raise ArgumentError, "#{mod.identifier} is not a plugin" unless parts.length >= 3

      type = ['plugin', 'cli', 'compute'].detect { |type| parts.include?(type) }
      raise ArgumentError, "#{mod.identifier} is not a plugin" unless type

      index = parts.index(type)
      if type == 'plugin'
        @group = parts.slice(0, index).join(' ')
      else
        @group = parts.slice(0, index + 1).join(' ')
      end
      @plugin, @provider = parts.slice(index + 1, parts.length)

      @module = mod
    end

    def name
      provider || plugin
    end

    def to_s
      mod.identifier
    end

    def inspect
      "<Plugin:#{mod.identifier}>"
    end

    def <=>(other)
      if group != other.group
        group <=> other.group
      elsif plugin != other.plugin
        plugin <=> other.plugin
      elsif provider
        if other.provider
          provider <=> other.provider
        else
          1
        end
      elsif other.provider
        -1
      else
        0
      end
    end
  end

  groups = Hash.new { |h, k| h[k] = [] }

  kafo.modules.each do |mod|
    begin
      plugin = Plugin.new(mod)
      groups[plugin.group] << plugin
    rescue ArgumentError
    end
  end

  if groups.any?
    groups.each do |group, plugins|
      say "* #{group.tr('_', ' ').capitalize}"
      plugins.sort.each do |plugin|
        enabled = plugin.module.enabled? ? 'enabled' : 'disabled'
        indenting = plugin.provider ? '    ' : '  '

        # TODO: assumes there is a plugin but breaks with
        # foreman_proxy::plugin::dns::powerdns because dns is built in
        say "#{indenting}* #{plugin.name} (#{enabled})"
      end
    end
  else
    say "No plugins available in #{scenario_data.name}"
  end

  exit(0)
end
