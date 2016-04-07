['foreman::plugin::ansible', 'foreman::plugin::cockpit', 'foreman::plugin::memcache', 'foreman_proxy::plugin::discovery'].each do |mod|
  mapping = scenario[:mapping].delete(mod)
  scenario[:mapping][mod.to_sym] ||= mapping if mapping
end
