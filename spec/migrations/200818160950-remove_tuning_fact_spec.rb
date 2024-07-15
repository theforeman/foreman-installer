require 'spec_helper'

migration '200818160950-remove_tuning_fact' do
  scenarios %w[foreman-proxy-content] do
    let(:config) { super().merge(:facts => { 'tuning' => 'default' }) }

    it 'removes facts' do
      expect(migrated_config).not_to include(:facts)
    end
  end
end
