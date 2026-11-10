require 'spec_helper'

describe 'tuning' do
  def tuning_profile(size)
    load_config_yaml("foreman.hiera/tuning/sizes/#{size}.yaml")
  end

  describe 'development' do
    subject(:tuning) { tuning_profile('development') }

    it 'limits Puma workers' do
      expect(tuning['foreman::foreman_service_puma_workers']).to eq(2)
    end

    it 'limits Pulp workers' do
      expect(tuning['foreman_proxy_content::pulpcore_worker_count']).to eq(2)
      expect(tuning['pulpcore::content_service_worker_count']).to eq(2)
      expect(tuning['pulpcore::api_service_worker_count']).to eq(2)
    end
  end
end
