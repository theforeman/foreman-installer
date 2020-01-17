module KatelloCertsHookContextExtension
  def read_cache_data(param)
    YAML.load_file("/opt/puppetlabs/puppet/cache/foreman_cache_data/#{param}")
  end
end

Kafo::HookContext.send(:include, KatelloCertsHookContextExtension)
