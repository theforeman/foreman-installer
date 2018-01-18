class Kafo::Helpers
  class << self
    def module_enabled?(kafo, name)
      mod = kafo.module(name)
      return false if mod.nil?
      mod.enabled?
    end

    def log_and_say(level, message)
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
      say "<%= color('#{escaped_message}', :#{style}) %>"
      Kafo::KafoConfigure.logger.send(level, message)
    end

    def execute(commands)
      commands = commands.is_a?(Array) ? commands : [commands]
      results = []

      commands.each do |command|
        output = `#{command} 2>&1`

        if $?.success?
          log_and_say(:debug, output.to_s)
          results << true
        else
          log_and_say(:error, output.to_s)
          results << false
        end
      end

      !results.include? false
    end
  end
end
