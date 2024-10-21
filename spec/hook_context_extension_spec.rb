require 'spec_helper'
require 'kafo/hook_context'
require_relative '../hooks/boot/01-kafo-hook-extensions'

describe HookContextExtension do
  let(:kafo) { instance_double(Kafo::KafoConfigure) }
  let(:logger) { instance_double(Kafo::Logger) }
  let(:context) { Kafo::HookContext.new(kafo, logger) }

  before do
    allow(context).to receive(:logger).and_return(logger)
  end

  describe '.ensure_packages' do
    subject { context.ensure_packages(packages, state) }

    let(:state) { 'installed' }

    context 'with no packages' do
      let(:packages) { [] }

      it 'returns without performing any action' do
        expect(subject).to be_nil
      end
    end

    context 'with packages' do
      let(:stdout) { '  StdOut    ' }
      let(:stderr) { ' StdErr  ' }
      let(:status) { instance_double(Process::Status, exitstatus: exitstatus) }
      let(:exitstatus) { nil }

      before do
        allow(logger).to receive(:info)
        allow(context).to receive(:apply_puppet_code).and_return([stdout, stderr, status])
      end

      context 'with a single package' do
        let(:packages) { ['vim-enhanced'] }

        [0, 2].each do |code|
          context "with exit code #{code}" do
            let(:exitstatus) { code }

            it 'calls Puppet successfully' do
              expect(subject).to be_nil

              expect(logger).to have_received(:info).with('Ensuring vim-enhanced to package state installed')
              expect(context).to have_received(:apply_puppet_code).with("package { ['vim-enhanced']: ensure => installed }")
            end
          end
        end

        context 'with exit code 1' do
          let(:exitstatus) { 1 }

          before do
            allow(context).to receive(:log_and_say)
            allow(logger).to receive(:debug)
            allow(context).to receive(:exit)
          end

          it 'calls Puppet, informs the user and exits' do
            expect(subject).to be_nil

            expect(context).to have_received(:log_and_say).with(:error, 'Failed to ensure vim-enhanced is installed')
            expect(context).to have_received(:log_and_say).with(:error, 'StdErr')
            expect(logger).to have_received(:debug).with('StdOut')
            expect(logger).to have_received(:debug).with('Exit status is 1')
            expect(context).to have_received(:exit).with(1)
          end
        end
      end

      context 'with multiple packages' do
        let(:packages) { ['vim-enhanced', 'emacs'] }

        before { allow(logger).to receive(:info) }

        [0, 2].each do |code|
          context "with exit code #{code}" do
            let(:exitstatus) { code }

            it 'calls Puppet successfully' do
              expect(subject).to be_nil

              expect(logger).to have_received(:info).with('Ensuring vim-enhanced, emacs to package state installed')
              expect(context).to have_received(:apply_puppet_code).with("package { ['vim-enhanced', 'emacs']: ensure => installed }")
            end
          end
        end

        context 'with exit code 1' do
          let(:exitstatus) { 1 }

          before do
            allow(context).to receive(:log_and_say)
            allow(logger).to receive(:debug)
            allow(context).to receive(:exit)
          end

          it 'calls Puppet, informs the user and exits' do
            expect(subject).to be_nil

            expect(context).to have_received(:log_and_say).with(:error, 'Failed to ensure vim-enhanced, emacs are installed')
            expect(context).to have_received(:log_and_say).with(:error, 'StdErr')
            expect(logger).to have_received(:debug).with('StdOut')
            expect(logger).to have_received(:debug).with('Exit status is 1')
            expect(context).to have_received(:exit).with(1)
          end
        end
      end
    end

    describe '.apply_puppet_code' do
      subject { context.apply_puppet_code(code) }

      before do
        allow(Kafo::PuppetCommand).to receive(:search_puppet_path).with('puppet').and_return('/bin/puppet')
        allow(Open3).to receive(:capture3).and_return('result')
      end

      after do
        expect(Kafo::PuppetCommand).to have_received(:search_puppet_path).twice
      end

      context 'with empty code' do
        let(:code) { '' }

        specify do
          expect(subject).to eq('result')
          expect(Open3).to have_received(:capture3).with(anything, 'echo "" | /bin/puppet apply --detailed-exitcodes', anything)
        end
      end

      context 'with some code' do
        let(:code) { "package { 'vim-enhanced': ensure => installed }" }

        specify do
          expect(subject).to eq('result')
          expect(Open3).to have_received(:capture3).with(anything, 'echo "package { \'vim-enhanced\': ensure => installed }" | /bin/puppet apply --detailed-exitcodes', anything)
        end
      end
    end

    describe '.execute!' do
      subject { context.execute!(command) }
      let(:command) { 'uptime' }

      before do
        allow(context).to receive(:execute_command).and_return([command, true])
      end

      it 'executes a command' do
        expect(subject).to eq(command)
        expect(context).to have_received(:execute_command).with(command, true, true)
      end
    end

    describe '.execute_as!' do
      subject { context.execute_as!(user, command) }
      let(:command) { 'uptime' }
      let(:user) { 'postgres' }

      before do
        allow(context).to receive(:execute!)
      end

      it 'executes a command' do
        expect(subject).to be_nil
        expect(context).to have_received(:execute!).with("runuser -l postgres -c 'uptime'", true, true)
      end
    end
  end
end
