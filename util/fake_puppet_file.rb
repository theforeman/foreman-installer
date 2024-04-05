require 'puppet_forge'
require 'semverse'

class FakePuppetfile
  def initialize
    @new_content = []
  end

  def forge(url)
    @new_content << ['forge', url, nil]
    PuppetForge.host = url
  end

  def mod(name, *version, **options)
    if options.any? && !options.include?(:ref)
      release = PuppetForge::Module.find(name.tr('/', '-')).current_release
      @new_content << ['mod', name, ["~> #{release.version}"]]
    else
      @new_content << ['mod', name, version]
    end
  end

  def content
    max_length = @new_content.select { |type, _value| type == 'mod' }.map { |_type, value| value.length }.max

    @new_content.each do |type, value, options|
      if type == 'forge'
        yield "forge '#{value}'"
        yield ""
      elsif type == 'mod'
        if options.empty?
          yield "mod '#{value}'"
        elsif options.is_a?(Array)
          padding = ' ' * (max_length - value.length)
          yield "mod '#{value}', #{padding}#{options.map { |version| "'#{version}'" }.join(', ')}"
        else
          padding = ' ' * (max_length - value.length)
          yield "mod '#{value}', #{padding}#{options.map { |k, v| ":#{k} => '#{v}'" }.join(', ')}"
        end
      end
    end
  end
end
