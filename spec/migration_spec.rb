require 'spec_helper'

describe 'with all migrations' do
  let(:config) { load_config_yaml("#{scenario_name}.yaml") }
  let(:answers) { load_config_yaml("#{scenario_name}-answers.yaml") }
  let(:migrations) { config_path("#{scenario_name}.migrations") }
  let(:migrator) { Kafo::Migrations.new(migrations).run(config, answers) }
  subject(:migrated_config) { migrator[0] }
  subject(:migrated_answers) { migrator[1] }

  context 'on the scenario' do
    %w[foreman foreman-proxy-content katello].each do |scenario_name|
      context scenario_name do
        let(:scenario_name) { scenario_name }

        it 'does not change the scenario config' do
          expect(migrated_config).to eq load_config_yaml("#{scenario_name}.yaml")
        end

        it 'does not change the scenario answers' do
          expect(migrated_answers).to eq load_config_yaml("#{scenario_name}-answers.yaml")
        end
      end
    end
  end

  context 'on katello' do
    let(:scenario_name) { 'katello' }
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

  context 'the migration 20210625142707_dynamic_puppet_in_foreman_groups' do
    let(:answers) do
      {
        'foreman' => {
          'user_groups' => ['puppet'],
        },
      }
    end

    %w[foreman katello].each do |scenario_name|
      context "on #{scenario_name}" do
        let(:scenario_name) { scenario_name }

        it 'removes puppet' do
          expect(migrated_answers['foreman']['user_groups']).to eq []
        end
      end
    end
  end

  context 'the migration 200818160950-remove_tuning_fact on foreman-proxy-content' do
    let(:scenario_name) { 'foreman-proxy-content' }
    let(:config) { super().merge(:facts => { 'tuning' => 'default' }) }

    it 'removes facts' do
      expect(migrated_config).not_to include(:facts)
    end
  end

  context 'the migration 20210929144850_disable_puppet_plugins_if_undesired' do
    let(:answers) do
      {
        'foreman' => false,
        'foreman::cli' => false,
      }
    end

    %w[foreman katello].each do |scenario_name|
      context "on #{scenario_name}" do
        let(:scenario_name) { scenario_name }

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
  end

  context 'the migration 20211108174119_disable_registration_without_templates' do
    %w[foreman foreman-proxy-content katello].each do |scenario_name|
      context "on #{scenario_name}" do
        let(:scenario_name) { scenario_name }

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
  end

  context 'the migration 181213211252-merged-installer' do
    let(:config) { load_fixture_yaml('merged-installer', "#{scenario_name}-before.yaml") }

    %w[foreman-proxy-content katello].each do |scenario_name|
      context "on #{scenario_name}" do
        let(:scenario_name) { scenario_name }

        it 'matches the scenario fixture' do
          expect(migrated_config).to eq load_fixture_yaml('merged-installer', "#{scenario_name}-after.yaml")
        end
      end
    end
  end

  context 'the migration 20220926102315_set_ansible_runner_repo_false_on_debian on foreman' do
    let(:scenario_name) { 'foreman' }
    let(:answers) do
      {
        'foreman_proxy::plugin::ansible' => {
          'manage_runner_repo' => true,
        },
      }
    end

    specify 'on Debian' do
      expect_any_instance_of(Kafo::MigrationContext).to receive(:facts).and_return({ os: { family: 'Debian' } })
      expect(migrated_answers['foreman_proxy::plugin::ansible']).not_to include('manage_runner_repo')
    end

    specify 'on RedHat' do
      expect_any_instance_of(Kafo::MigrationContext).to receive(:facts).and_return({ os: { family: 'RedHat' } })
      expect(migrated_answers['foreman_proxy::plugin::ansible']).to include('manage_runner_repo')
    end
  end
end
