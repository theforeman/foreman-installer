require 'spec_helper'
require 'kafo/hook_context'

require_relative '../hooks/boot/01-kafo-hook-extensions'
require_relative '../hooks/boot/06-postgresql-upgrade-extensions'

describe PostgresqlUpgradeHookContextExtension do
  let(:kafo) { instance_double(Kafo::KafoConfigure) }
  let(:logger) { instance_double(Kafo::Logger) }
  let(:context) { Kafo::HookContext.new(kafo, logger) }

  describe '.needs_postgresql_upgrade?' do
    subject { context.needs_postgresql_upgrade?(16) }

    it 'returns true for PostgreSQL 13' do
      expect(File).to receive(:read).with('/var/lib/pgsql/data/PG_VERSION').and_return('13')
      expect(subject).to be_truthy
    end

    it 'returns false for PostgreSQL 16' do
      expect(File).to receive(:read).with('/var/lib/pgsql/data/PG_VERSION').and_return('16')
      expect(subject).to be_falsy
    end

    it 'returns false when no PostgreSQL version file was found' do
      expect(File).to receive(:read).with('/var/lib/pgsql/data/PG_VERSION').and_raise(Errno::ENOENT)
      expect(subject).to be_falsy
    end
  end

  describe '.os_needs_postgresql_upgrade?' do
    before do
      allow(context).to receive(:el9?).and_return(false)
      allow(context).to receive(:needs_postgresql_upgrade?).with(16).and_return(true)
    end

    it 'runs on EL9' do
      allow(context).to receive(:el9?).and_return(true)
      expect(context.os_needs_postgresql_upgrade?).to be_truthy
    end

    it 'does not run on EL10' do
      allow(context).to receive(:el10?).and_return(true)
      expect(context.os_needs_postgresql_upgrade?).to be_falsy
    end

    it 'does not run on other operating systems' do
      expect(context.os_needs_postgresql_upgrade?).to be_falsy
    end
  end

  describe '.postgresql_upgrade_path' do
    subject { context.postgresql_upgrade_path(source, 16) }

    before do
      allow(context).to receive(:el9?).and_return(false)
    end

    context 'on EL9' do
      let(:source) { 13 }

      it 'upgrades PostgreSQL 13 through 15 to 16' do
        allow(context).to receive(:el9?).and_return(true)
        expect(subject).to eq([15, 16])
      end
    end
  end

  describe '.postgresql_upgrade' do
    let(:logger) { instance_double(Kafo::Logger, notice: nil) }

    before do
      allow(context).to receive(:logger).and_return(logger)
      allow(context).to receive(:current_version).and_return('13')
      allow(context).to receive(:el9?).and_return(false)
      allow(context).to receive(:postgresql_upgrade_step)
    end

    it 'runs the supported two-step EL9 upgrade' do
      allow(context).to receive(:el9?).and_return(true)

      expect(context).to receive(:postgresql_upgrade_step).with(13, 15).ordered
      expect(context).to receive(:postgresql_upgrade_step).with(15, 16).ordered

      context.postgresql_upgrade(16)

      expect(logger).to have_received(:notice).with('Performing upgrade of PostgreSQL from 13 to 16')
    end
  end

  describe '.postgresql_upgrade_step' do
    let(:logger) { instance_double(Kafo::Logger, notice: nil) }
    let(:locale_query) do
      "echo \"select datcollate,datctype from pg_database where datname='postgres';\" | runuser -l postgres -c '/usr/lib64/pgsql/postgresql-13/bin/postgres --single -D /var/lib/pgsql/data postgres'"
    end
    let(:locale_result) do
      <<~PSQL
        1: datcollate = "en_US.UTF-8"
        2: datctype = "en_US.UTF-8"
      PSQL
    end

    before do
      allow(context).to receive(:logger).and_return(logger)
      allow(context).to receive_messages(
        execute!: nil,
        execute: false,
        execute_as!: nil,
        stop_services: nil,
        ensure_packages: nil,
        start_services: nil,
        preserve_previous_postgresql_data: nil
      )
      allow(context).to receive(:`).with(locale_query).and_return(locale_result)
    end

    it 'switches the EL9 DNF module and installs the upgrade packages' do
      context.postgresql_upgrade_step(13, 15)

      expect(context).to have_received(:execute!).with('dnf module switch-to postgresql:15 -y', false, true)
      expect(context).to have_received(:ensure_packages).with(
        ['postgresql', 'postgresql-server', 'postgresql-upgrade'], 'latest'
      )
    end
  end

  describe '.preserve_previous_postgresql_data' do
    it 'renames the previous data directory with its PostgreSQL version' do
      expect(File).to receive(:directory?).with('/var/lib/pgsql/data-old').and_return(true)
      expect(File).to receive(:read).with('/var/lib/pgsql/data-old/PG_VERSION').and_return('15')
      expect(File).to receive(:exist?).with('/var/lib/pgsql/data-old-15').and_return(false)
      expect(context).to receive(:execute!).with('mv /var/lib/pgsql/data-old /var/lib/pgsql/data-old-15', false, true)

      context.preserve_previous_postgresql_data
    end
  end

  describe '.check_postgresql_storage' do
    before do
      allow(context).to receive(:current_version).and_return('13')
      allow(context).to receive(:`).with('du --bytes --summarize /var/lib/pgsql/data').and_return("1024 /var/lib/pgsql/data\n")
      allow(context).to receive(:available_space).with('/var/lib/pgsql').and_return(2048)
      allow(context).to receive(:el9?).and_return(false)
    end

    it 'accounts for both EL9 upgrade steps' do
      allow(context).to receive(:el9?).and_return(true)

      expect(context.check_postgresql_storage(16)).to be_nil
    end
  end

  describe 'EL10 Hiera configuration' do
    it 'selects PostgreSQL 16 without enabling DNF module management' do
      config = load_config_yaml('foreman.hiera/family/RedHat-10.yaml')
      expect(config['postgresql::globals::manage_dnf_module']).to be(false)
      expect(config['postgresql::globals::version']).to eq('16')
    end
  end
end
