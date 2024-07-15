require 'spec_helper'

migration '20231005004305_redis_default_cache' do
  scenarios %w[foreman katello] do
    context 'changes default cache to Redis' do
      let(:answers) do
        {
          'foreman' => {
            'rails_cache_store' => { 'type' => 'file' },
          },
        }
      end

      it 'changes the default to Redis' do
        expect(migrated_answers['foreman']['rails_cache_store']).to eq({ 'type' => 'redis' })
      end
    end
  end
end
