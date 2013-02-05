# foreman_create_resources is a wrapper around the built in create_resources
# on 2.7+ and falls back to a standalone implementation on 2.6.
#
# This implementation imported from
#   https://github.com/puppetlabs/puppetlabs-create_resources @ 28584b0ed187
# All credit / copyright to Puppet Labs for this file
#
Puppet::Parser::Functions::newfunction(:foreman_create_resources, :doc => '
Converts a hash into a set of resources and adds them to the catalog.
Takes two parameters:
  foreman_create_resource($type, $resources)
    Creates resources of type $type from the $resources hash. Assumes that
    hash is in the following form:
     {title=>{parameters}}
  This is currently tested for defined resources, classes, as well as native types
') do |args|
  # Call the real create_resources function if it exists (2.7+)
  if Puppet::Parser::Functions::function(:create_resources)
    function_create_resources(args)
  else
    # Use separate implementation
    raise ArgumentError, ("foreman_create_resources(): wrong number of arguments (#{args.length}; must be 2)") if args.length != 2
    #raise ArgumentError, 'requires resource type and param hash' if args.size < 2
    # figure out what kind of resource we are
    type_of_resource = nil
    type_name = args[0].downcase
    if type_name == 'class'
      type_of_resource = :class
    else
      if resource = Puppet::Type.type(type_name.to_sym)
        type_of_resource = :type
      elsif resource = find_definition(type_name.downcase)
        type_of_resource = :define
      else 
        raise ArgumentError, "could not create resource of unknown type #{type_name}"
      end
    end
    # iterate through the resources to create
    args[1].each do |title, params|
      raise ArgumentError, 'params should not contain title' if(params['title'])
      case type_of_resource
      when :type
        res = resource.hash2resource(params.merge(:title => title))
        catalog.add_resource(res)
      when :define
        p_resource = Puppet::Parser::Resource.new(type_name, title, :scope => self, :source => resource)
        params.merge(:name => title).each do |k,v|
          p_resource.set_parameter(k,v)
        end
        resource.instantiate_resource(self, p_resource)
        compiler.add_resource(self, p_resource)
      when :class
        klass = find_hostclass(title)
        raise ArgumentError, "could not find hostclass #{title}" unless klass
        klass.ensure_in_catalog(self, params)
        compiler.catalog.add_class([title])
      end
    end
  end
end
