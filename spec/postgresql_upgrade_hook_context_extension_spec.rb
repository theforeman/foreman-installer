require 'spec_helper'
require 'kafo/hook_context'

require_relative '../hooks/boot/06-postgresql-upgrade-extensions'

describe PostgresqlUpgradeHookContextExtension do
  let(:kafo) { instance_double(Kafo::KafoConfigure) }
  let(:logger) { instance_double(Kafo::Logger) }
  let(:context) { Kafo::HookContext.new(kafo, logger) }

  describe '.needs_postgresql_upgrade?' do
    subject { context.needs_postgresql_upgrade?(13) }

    it 'returns true for PostgreSQL 12' do
      expect(File).to receive(:read).with('/var/lib/pgsql/data/PG_VERSION').and_return('12')
      expect(subject).to be_truthy
    end

    it 'returns false for PostgreSQL 13' do
      expect(File).to receive(:read).with('/var/lib/pgsql/data/PG_VERSION').and_return('13')
      expect(subject).to be_falsy
    end

    it 'returns false when no PostgreSQL version file was found' do
      expect(File).to receive(:read).with('/var/lib/pgsql/data/PG_VERSION').and_raise(Errno::ENOENT)
      expect(subject).to be_falsy
    end
  end

  describe '.postgresql_upgrade' do
    subject { context.postgresql_upgrade(13) }

    before do
      allow(File).to receive(:read).with('/var/lib/pgsql/data/PG_VERSION').and_return('12')
      allow(context).to receive(:logger).and_return(logger)
      allow(context).to receive(:'execute!')
      allow(context).to receive(:ensure_packages)
      allow(context).to receive(:stop_services)
      allow(context).to receive(:start_services)
      allow(context).to receive(:'`').with("echo \"select datcollate,datctype from pg_database where datname='postgres';\" | runuser -l postgres -c '/usr/lib64/pgsql/postgresql-12/bin/postgres --single -D /var/lib/pgsql/data postgres'")
                                     .and_return(<<~PSQL
        PostgreSQL stand-alone backend 12.18
        backend> 	 1: datcollate	(typeid = 19, len = 64, typmod = -1, byval = f)
        	 2: datctype	(typeid = 19, len = 64, typmod = -1, byval = f)
        	----
        	 1: datcollate = "en_US.UTF-8"	(typeid = 19, len = 64, typmod = -1, byval = f)
        	 2: datctype = "en_US.UTF-8"	(typeid = 19, len = 64, typmod = -1, byval = f)
        	----
        backend>
      PSQL
                                                )
      allow(logger).to receive(:notice)
    end

    it 'logs the upgrade' do
      expect(subject).to be_nil
      expect(logger).to have_received(:notice).with('Performing upgrade of PostgreSQL to 13')
      expect(logger).to have_received(:notice).with('Upgrade to PostgreSQL 13 completed')
    end

    it 'switches the dnf module' do
      expect(subject).to be_nil
      expect(context).to have_received(:'execute!').with('dnf module switch-to postgresql:13 -y', false, true)
    end

    it 'removes data_directory from postgresql.conf' do
      expect(subject).to be_nil
      expect(context).to have_received(:'execute!').with("sed -i '/^data_directory/d' /var/lib/pgsql/data/postgresql.conf", false, true)
    end

    it 'runs postgresql-setup --upgrade' do
      expect(subject).to be_nil
      expect(context).to have_received(:'execute!').with("runuser -l postgres -c 'PGSETUP_INITDB_OPTIONS=\"--lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8 --locale=en_US.UTF-8\" postgresql-setup --upgrade'", false, true)
    end

    it 'runs vacuumdb --all --analyze-in-stages' do
      expect(subject).to be_nil
      expect(context).to have_received(:'execute!').with("runuser -l postgres -c 'vacuumdb --all --analyze-in-stages'", false, true)
    end
  end
end
