require 'spec_helper'
require 'tmpdir'
require 'fileutils'
require 'kafo/hook_context'

describe 'rename_naming_convention' do
  let(:config) { instance_double('Kafo::Configuration') }
  let(:kafo) { instance_double('Kafo::KafoConfigure') }
  let(:logger) { instance_double('Logger') }
  let(:migrations_dir) { Dir.mktmpdir('installer-rename_naming_convention-') }
  let(:applied) { File.join(migrations_dir, '.applied') }
  let(:new_migration_name) { '20201217175955_stricter_ciphers' }

  subject do
    file = 'hooks/pre_migrations/rename_naming_convention.rb'
    hook = File.read(file)
    hook_block = proc { instance_eval(hook, file, 1) }
    Kafo::HookContext.execute(kafo, logger, &hook_block)
  end

  before do
    allow(kafo).to receive(:config).and_return(config)
    allow(config).to receive(:migrations_dir).and_return(migrations_dir)
    allow(Kafo).to receive(:request_config_reload)
  end

  after do
    FileUtils.rm_r(migrations_dir)
  end

  describe 'no migrations' do
    it do
      expect(subject).to match_array([])
      expect(Kafo).not_to have_received(:request_config_reload)
    end
  end

  describe 'with migrations' do
    before do
      FileUtils.touch(File.join(migrations_dir, "#{new_migration_name}.rb"))
    end

    context 'without an applied' do
      it do
        expect(subject).to match_array([])
        expect(Kafo).not_to have_received(:request_config_reload)
      end
    end

    context 'with an applied' do
      before do
        File.write(applied, applied_content.to_yaml)
      end

      context 'that is empty' do
        let(:applied_content) { [] }

        it do
          expect(subject).to match_array([])
          expect(Kafo::Migrations.new(migrations_dir).applied).to match_array([])
          expect(Kafo).not_to have_received(:request_config_reload)
        end
      end

      context 'that has a renamed migration' do
        let(:applied_content) { ['201217175955-stricter-ciphers'] }

        it do
          expect(subject).to match_array(['201217175955-stricter-ciphers'])
          expect(Kafo::Migrations.new(migrations_dir).applied).to match_array([new_migration_name])
          expect(Kafo).to have_received(:request_config_reload).once
        end
      end

      context 'that has multiple renamed migrations' do
        # This just renames dashes to underscores, already has YYYY
        before do
          FileUtils.touch(File.join(migrations_dir, "20210331121715_clear_puppetserver_nil_metrics.rb"))
        end

        let(:applied_content) { ['20210331121715_clear_puppetserver-nil-metrics', '201217175955-stricter-ciphers'] }

        it do
          expect(subject).to match_array(['20210331121715_clear_puppetserver-nil-metrics', '201217175955-stricter-ciphers'])
          expect(Kafo::Migrations.new(migrations_dir).applied).to match_array(['20210331121715_clear_puppetserver_nil_metrics', new_migration_name])
          expect(Kafo).to have_received(:request_config_reload).once
        end
      end

      context 'that has a removed migration' do
        let(:applied_content) { ['has-been-removed'] }

        it do
          expect(subject).to match_array([])
          expect(Kafo::Migrations.new(migrations_dir).applied).to match_array(['has-been-removed'])
          expect(Kafo).not_to have_received(:request_config_reload)
        end
      end

      context 'that is up to date' do
        let(:applied_content) { [new_migration_name] }

        it do
          expect(subject).to match_array([])
          expect(Kafo::Migrations.new(migrations_dir).applied).to match_array([new_migration_name])
          expect(Kafo).not_to have_received(:request_config_reload)
        end
      end
    end
  end
end
