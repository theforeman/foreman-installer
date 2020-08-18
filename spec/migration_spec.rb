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

    context "pulpcore migration dont proxy yum" do
      let(:answers_after) { load_fixture_yaml('pulpcore-migration-dont-proxy-yum', "#{scenario_name}-answers-after.yaml") }
      let(:scenario) do
        {
          :answers    => load_fixture_yaml('pulpcore-migration-dont-proxy-yum', "#{scenario_name}-answers-before.yaml"),
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
end
