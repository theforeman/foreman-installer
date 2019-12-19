class Kafo
  class Helpers
    class << self
      def read_cache_data(param)
        YAML.load_file("/opt/puppetlabs/puppet/cache/foreman_cache_data/#{param}")
      end
    end
  end
end
