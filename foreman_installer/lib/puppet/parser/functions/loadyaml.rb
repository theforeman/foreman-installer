module Puppet::Parser::Functions

  newfunction(:loadyaml, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Load a YAML file containing an array, string, or hash, and return the data
    in the corresponding native data type.

    For example:

        $myhash = loadyaml('/etc/puppet/data/myhash.yaml')
    ENDHEREDOC

    args.delete_if { |filename| not File.exist? filename }

    if args.length == 0
      raise Puppet::ParseError, ("loadyaml(): No files to load")
    end

    YAML.load_file(args[0])

  end

end
