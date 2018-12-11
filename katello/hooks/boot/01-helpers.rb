class Kafo::Helpers
  class << self
    def module_enabled?(kafo, name)
      mod = kafo.module(name)
      return false if mod.nil?
      mod.enabled?
    end

    def log_and_say(level, message, do_say = true, do_log = true)
      style = case level
              when :error
                'bad'
              when :debug
                'yellow'
              else
                level
              end

      # \ and ' characters could cause trouble in ERB, make sure to escape them
      escaped_message = message.gsub('\\', '\\\\\\').gsub("'", %q{\\\'})
      say "<%= color('#{escaped_message}', :#{style}) %>" if do_say
      Kafo::KafoConfigure.logger.send(level, message) if do_log
    end

    def read_cache_data(param)
      YAML.load_file("/opt/puppetlabs/puppet/cache/foreman_cache_data/#{param}")
    end

    def execute(commands, do_say = true, do_log = true)
      commands = commands.is_a?(Array) ? commands : [commands]
      results = []
      commands.each do |command|
        results << execute_command(command, do_say, do_log)
      end
      !results.include? false
    end

    def execute_command(command, do_say, do_log)
      process = IO.popen("#{command} 2>&1") do |io|
        while line = io.gets
          line.chomp!
          log_and_say(:debug, line, do_say, do_log)
        end
        io.close
        if $?.success?
          log_and_say(:debug, "#{command} finished successfully!", do_say, do_log)
        else
          log_and_say(:error, "#{command} failed! Check the output for error!", do_say, do_log)
        end
        $?.success?
      end
    end
  end
end

# FIXME: remove when #23332 is released
module HookContextExtension
  def param_value(mod, name)
    param(mod, name).value if param(mod, name)
  end
end

unless Kafo::HookContext.method_defined?(:param_value)
  Kafo::HookContext.send(:include, HookContextExtension)
end
