require 'spec_helper'

describe 'migrations' do
  %w[foreman foreman-proxy-content katello].each do |scenario_name|
    context "on #{scenario_name}" do
      let(:answers) { load_config_yaml("#{scenario_name}-answers.yaml") }
      let(:config) { load_config_yaml("#{scenario_name}.yaml") }
      let(:scenario) do
        {
          :answers    => load_config_yaml("#{scenario_name}-answers.yaml"),
          :config     => load_config_yaml("#{scenario_name}.yaml"),
          :migrations => config_path("#{scenario_name}.migrations"),
        }
      end

      let(:migrator) { Kafo::Migrations.new(scenario[:migrations]).run(scenario[:config], scenario[:answers]) }

      it 'does not change scenario config' do
        after, = migrator
        expect(config).to eq after
      end

      it 'does not change scenario answers' do
        _, after = migrator
        expect(answers).to eq after
      end
    end
  end

  %w[foreman-proxy-content katello].each do |scenario_name|
    context "migrates #{scenario_name} split installer" do
      let(:config_after) { load_fixture_yaml('merged-installer', "#{scenario_name}-after.yaml") }
      let(:scenario) do
        {
          :answers    => load_config_yaml("#{scenario_name}-answers.yaml"),
          :config     => load_fixture_yaml('merged-installer', "#{scenario_name}-before.yaml"),
          :migrations => config_path("#{scenario_name}.migrations"),
        }
      end

      let(:migrator) { Kafo::Migrations.new(scenario[:migrations]).run(scenario[:config], scenario[:answers]) }

      it 'does not change scenario config' do
        after, = migrator
        expect(after).to eq config_after
      end
    end
  end

  %w[katello].each do |scenario_name|
    context "pulpcore migration" do
      let(:answers_after) { load_fixture_yaml('pulpcore-migration', "#{scenario_name}-answers-after.yaml") }
      let(:scenario) do
        {
          :answers    => load_fixture_yaml('pulpcore-migration', "#{scenario_name}-answers-before.yaml"),
          :config     => load_config_yaml("#{scenario_name}.yaml"),
          :migrations => config_path("#{scenario_name}.migrations"),
        }
      end

      let(:migrator) { Kafo::Migrations.new(scenario[:migrations]).run(scenario[:config], scenario[:answers]) }

      it 'changes scenario answers' do
        _, after = migrator
        expect(answers_after).to eq after
      end
    end

    context "pulpcore migration rpm plugin only" do
      let(:answers_after) { load_fixture_yaml('pulpcore-migration-rpm-only', "#{scenario_name}-answers-after.yaml") }
      let(:scenario) do
        {
          :answers    => load_fixture_yaml('pulpcore-migration-rpm-only', "#{scenario_name}-answers-before.yaml"),
          :config     => load_config_yaml("#{scenario_name}.yaml"),
          :migrations => config_path("#{scenario_name}.migrations"),
        }
      end

      let(:migrator) { Kafo::Migrations.new(scenario[:migrations]).run(scenario[:config], scenario[:answers]) }

      it 'changes scenario answers' do
        _, after = migrator
        expect(answers_after).to eq after
      end
    end

    context "pulpcore migration dont use content plugins on upgrades" do
      let(:answers_after) { load_fixture_yaml('pulpcore-migration-dont-use-content-plugins-on-upgrades', "#{scenario_name}-answers-after.yaml") }
      let(:scenario) do
        {
          :answers    => load_fixture_yaml('pulpcore-migration-dont-use-content-plugins-on-upgrades', "#{scenario_name}-answers-before.yaml"),
          :config     => load_config_yaml("#{scenario_name}.yaml"),
          :migrations => config_path("#{scenario_name}.migrations"),
        }
      end

      let(:migrator) { Kafo::Migrations.new(scenario[:migrations]).run(scenario[:config], scenario[:answers]) }

      it 'changes scenario answers' do
        _, after = migrator
        expect(answers_after).to eq after
      end
    end
  end

  %w[foreman-proxy-content].each do |scenario_name|
    context "foreman-proxy-content remove tuning fact" do
      let(:config_after) { load_fixture_yaml('foreman-proxy-content-remove-tuning-fact', "#{scenario_name}-after.yaml") }
      let(:scenario) do
        {
          :answers    => load_config_yaml("#{scenario_name}-answers.yaml"),
          :config     => load_fixture_yaml('foreman-proxy-content-remove-tuning-fact', "#{scenario_name}-before.yaml"),
          :migrations => config_path("#{scenario_name}.migrations"),
        }
      end

      let(:migrator) { Kafo::Migrations.new(scenario[:migrations]).run(scenario[:config], scenario[:answers]) }

      it 'changes scenario config' do
        after, = migrator
        expect(config_after).to eq after
      end
    end
  end

  %w[foreman katello].each do |scenario_name|
    context "foreman drop puppet from user_groups" do
      let(:answers_after) { load_fixture_yaml('cleanup-foreman-user-groups', "#{scenario_name}-answers-after.yaml") }
      let(:scenario) do
        {
          :answers    => load_fixture_yaml('cleanup-foreman-user-groups', "#{scenario_name}-answers-before.yaml"),
          :config     => load_config_yaml("#{scenario_name}.yaml"),
          :migrations => config_path("#{scenario_name}.migrations"),
        }
      end

      let(:migrator) { Kafo::Migrations.new(scenario[:migrations]).run(scenario[:config], scenario[:answers]) }

      it 'changes scenario answers' do
        _, after = migrator
        expect(after).to include answers_after
      end
    end
  end

  context 'disable puppet if needed' do
    %w[foreman katello].each do |scenario_name|
      context "on #{scenario_name}" do
        let(:answers) do
          {
            'foreman' => false,
            'foreman::cli' => false,
          }
        end
        let(:scenario_name) { scenario_name }
        let(:config) { load_config_yaml("#{scenario_name}.yaml") }
        let(:migrations) { config_path("#{scenario_name}.migrations") }
        let(:migrator) { Kafo::Migrations.new(migrations).run(config, answers) }
        subject(:migrated_answers) { migrator[1] }

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
end
