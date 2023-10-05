require 'spec_helper'

migration 'all migrations' do
  scenarios %w[foreman foreman-proxy-content katello] do
    it 'does not change the scenario config' do
      expect(migrated_config).to eq load_config_yaml("#{scenario_name}.yaml")
    end

    it 'does not change the scenario answers' do
      expect(migrated_answers).to eq load_config_yaml("#{scenario_name}-answers.yaml")
    end
  end

  scenarios %w[katello] do
    let(:answers) { load_fixture_yaml(fixture, "#{scenario_name}-answers-before.yaml") }
    let(:expected_answers) { load_fixture_yaml(fixture, "#{scenario_name}-answers-after.yaml") }

    ['pulpcore-migration', 'pulpcore-migration-rpm-only', 'pulpcore-migration-dont-use-content-plugins-on-upgrades'].each do |fixture_name|
      context "with fixture #{fixture_name}" do
        let(:fixture) { fixture_name }

        it 'matches the answers fixture' do
          expect(migrated_answers).to eq expected_answers
        end
      end
    end
  end
end

migration '20210625142707_dynamic_puppet_in_foreman_groups' do
  let(:answers) do
    {
      'foreman' => {
        'user_groups' => ['puppet'],
      },
    }
  end

  scenarios %w[foreman katello] do
    it 'removes puppet' do
      expect(migrated_answers['foreman']['user_groups']).to eq []
    end
  end
end

migration '200818160950-remove_tuning_fact' do
  scenarios %w[foreman-proxy-content] do
    let(:config) { super().merge(:facts => { 'tuning' => 'default' }) }

    it 'removes facts' do
      expect(migrated_config).not_to include(:facts)
    end
  end
end

migration '20210929144850_disable_puppet_plugins_if_undesired' do
  let(:answers) do
    {
      'foreman' => false,
      'foreman::cli' => false,
    }
  end

  scenarios %w[foreman katello] do
    it 'keeps foreman::cli disabled' do
      expect(migrated_answers['foreman::cli']).to be false
    end

    it 'adds foreman::cli::puppet disabled' do
      expect(migrated_answers['foreman::cli::puppet']).to be false
    end

    it 'keeps foreman disabled' do
      expect(migrated_answers['foreman']).to be false
    end

    it 'adds foreman::plugin::puppet disabled' do
      expect(migrated_answers['foreman::plugin::puppet']).to be false
    end
  end
end

migration '20211108174119_disable_registration_without_templates' do
  scenarios %w[foreman foreman-proxy-content katello] do
    context 'with registration, without templates' do
      let(:answers) do
        {
          'foreman_proxy' => {
            'registration' => true,
            'templates' => false,
          },
        }
      end

      it 'disables registration' do
        expect(migrated_answers['foreman_proxy']['registration']).to be false
      end
    end

    context 'with registration, with templates' do
      let(:answers) do
        {
          'foreman_proxy' => {
            'registration' => true,
            'templates' => true,
          },
        }
      end

      it 'keeps registration enabled' do
        expect(migrated_answers['foreman_proxy']['registration']).to be true
      end
    end
  end
end

migration '181213211252-merged-installer' do
  let(:config) { load_fixture_yaml('merged-installer', "#{scenario_name}-before.yaml") }

  scenarios %w[foreman-proxy-content katello] do
    it 'matches the scenario fixture' do
      expect(migrated_config).to eq load_fixture_yaml('merged-installer', "#{scenario_name}-after.yaml")
    end
  end
end

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
