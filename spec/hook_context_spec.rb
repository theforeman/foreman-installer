require 'spec_helper'
require 'kafo/hook_context'
require_relative '../hooks/boot/01-kafo-hook-extensions'

describe 'HookContextExtension' do
  let(:kafo) { instance_double('KafoConfigure') }
  let(:logger) { instance_double('Logger') }
  let(:context) { Kafo::HookContext.new(kafo) }

  before do
    allow(context).to receive(:logger).and_return(logger)
  end

  context 'ensure_packages' do
    let(:state) { 'installed' }
    subject { context.ensure_packages(packages, state) }

    context 'no packages' do
      let(:packages) { [] }

      it 'returns without performing any action' do
        is_expected.to be_nil
      end
    end

    context 'with packages' do
      let(:stdout) { '  StdOut    ' }
      let(:stderr) { ' StdErr  ' }
      let(:status) { instance_double('Process::Status', exitstatus: exitstatus) }
      let(:exitstatus) { nil }

      before do
        allow(logger).to receive(:info)
        allow(context).to receive(:apply_puppet_code).and_return([stdout, stderr, status])
      end

      context 'single package' do
        let(:packages) { ['vim-enhanced'] }

        [0, 2].each do |code|
          context "exit code #{code}" do
            let(:exitstatus) { code }

            it 'calls Puppet successfully' do
              is_expected.to be_nil

              expect(logger).to have_received(:info).with('Ensuring vim-enhanced to package state installed')
              expect(context).to have_received(:apply_puppet_code).with("package { ['vim-enhanced']: ensure => installed }")
            end
          end
        end

        context 'exit code 1' do
          let(:exitstatus) { 1 }

          before do
            allow(context).to receive(:log_and_say)
            allow(logger).to receive(:debug)
            allow(context).to receive(:exit)
          end

          it 'calls Puppet, informs the user and exits' do
            is_expected.to be_nil

            expect(context).to have_received(:log_and_say).with(:error, 'Failed to ensure vim-enhanced is installed')
            expect(context).to have_received(:log_and_say).with(:error, 'StdErr')
            expect(logger).to have_received(:debug).with('StdOut')
            expect(logger).to have_received(:debug).with('Exit status is 1')
            expect(context).to have_received(:exit).with(1)
          end
        end
      end

      context 'multiple packages' do
        let(:packages) { ['vim-enhanced', 'emacs'] }

        before { allow(logger).to receive(:info) }

        [0, 2].each do |code|
          context "exit code #{code}" do
            let(:exitstatus) { code }

            it 'calls Puppet successfully' do
              is_expected.to be_nil

              expect(logger).to have_received(:info).with('Ensuring vim-enhanced, emacs to package state installed')
              expect(context).to have_received(:apply_puppet_code).with("package { ['vim-enhanced', 'emacs']: ensure => installed }")
            end
          end
        end

        context 'exit code 1' do
          let(:exitstatus) { 1 }

          before do
            allow(context).to receive(:log_and_say)
            allow(logger).to receive(:debug)
            allow(context).to receive(:exit)
          end

          it 'calls Puppet, informs the user and exits' do
            is_expected.to be_nil

            expect(context).to have_received(:log_and_say).with(:error, 'Failed to ensure vim-enhanced, emacs are installed')
            expect(context).to have_received(:log_and_say).with(:error, 'StdErr')
            expect(logger).to have_received(:debug).with('StdOut')
            expect(logger).to have_received(:debug).with('Exit status is 1')
            expect(context).to have_received(:exit).with(1)
          end
        end
      end
    end

    context 'apply_puppet_code' do
      subject { context.apply_puppet_code(code) }

      before do
        allow(Kafo::PuppetCommand).to receive(:search_puppet_path).with('puppet').and_return('/bin/puppet')
        allow(Open3).to receive(:capture3).and_return('result')
      end

      after do
        expect(Kafo::PuppetCommand).to have_received(:search_puppet_path)
      end

      context 'empty code' do
        let(:code) { '' }

        specify do
          is_expected.to eq('result')
          expect(Open3).to have_received(:capture3).with('echo "" | /bin/puppet apply --detailed-exitcodes')
        end
      end

      context 'some code' do
        let(:code) { "package { 'vim-enhanced': ensure => installed }" }

        specify do
          is_expected.to eq('result')
          expect(Open3).to have_received(:capture3).with('echo "package { \'vim-enhanced\': ensure => installed }" | /bin/puppet apply --detailed-exitcodes')
        end
      end
    end
  end
end
