require 'spec_helper'
require 'kafo/hook_context'
require_relative '../hooks/boot/04-services'

describe 'ForemanMaintainHookContextExtension' do
  let(:kafo) { instance_double('KafoConfigure') }
  let(:logger) { instance_double('Logger') }
  let(:context) { Kafo::HookContext.new(kafo) }

  before do
    allow(context).to receive(:logger).and_return(logger)
    allow(context).to receive(:fail_and_exit).and_raise(RuntimeError, 'called fail_and_exit')
  end

  context 'start_services' do
    subject { context.start_services(services) }

    context 'no services' do
      let(:services) { [] }

      it { expect { subject }.to raise_error(RuntimeError, 'Services must be specified') }
    end

    context 'with services' do
      let(:output) { 'StdOut and StdErr' }
      let(:status) { instance_double('Process::Status', exitstatus: exitstatus) }

      before do
        allow(logger).to receive(:debug)
        allow(Open3).to receive(:capture2e).and_return([output, status])
        allow(status).to receive(:success?).and_return(exitstatus == 0)
      end

      context 'single service' do
        let(:services) { ['httpd'] }

        context 'exit status 0' do
          let(:exitstatus) { 0 }

          it 'runs successfully' do
            is_expected.to be_nil

            expect(logger).to have_received(:debug).with('Starting services httpd')
            expect(Open3).to have_received(:capture2e).with('systemctl', 'start', 'httpd')
          end
        end

        context 'exit status 1' do
          let(:exitstatus) { 1 }

          before do
            allow(context).to receive(:exit)
          end

          it 'exits with an error' do
            expect { subject }.to raise_error(RuntimeError, 'called fail_and_exit')

            expect(logger).to have_received(:debug).with('Starting services httpd')
            expect(context).to have_received(:fail_and_exit).with('Failed to start services: StdOut and StdErr', 1)
          end
        end
      end

      context 'multiple services' do
        let(:services) { ['foreman', 'foreman-proxy'] }

        context 'exit status 0' do
          let(:exitstatus) { 0 }

          it 'runs successfully' do
            is_expected.to be_nil

            expect(logger).to have_received(:debug).with('Starting services foreman, foreman-proxy')
            expect(Open3).to have_received(:capture2e).with('systemctl', 'start', 'foreman', 'foreman-proxy')
          end
        end

        context 'exit status 2' do
          let(:exitstatus) { 2 }

          before do
            allow(context).to receive(:exit)
          end

          it 'exits with an error' do
            expect { subject }.to raise_error(RuntimeError, 'called fail_and_exit')

            expect(logger).to have_received(:debug).with('Starting services foreman, foreman-proxy')
            expect(context).to have_received(:fail_and_exit).with('Failed to start services: StdOut and StdErr', 2)
          end
        end
      end
    end
  end

  context 'stop_services' do
    subject { context.stop_services(services) }

    context 'no services' do
      let(:services) { [] }

      it { expect { subject }.to raise_error(RuntimeError, "Can't stop all services") }
    end

    context 'with service' do
      let(:list_cmd_status) { instance_double('Process::Status', exitstatus: list_cmd_exitstatus) }
      let(:stop_cmd_status) { instance_double('Process::Status', exitstatus: stop_cmd_exitstatus) }

      before do
        allow(logger).to receive(:debug)
        allow(Open3).to receive(:capture3).and_return([list_cmd_stdout, list_cmd_stderr, list_cmd_status])
        allow(list_cmd_status).to receive(:success?).and_return(list_cmd_exitstatus == 0)
      end

      context 'httpd.service' do
        let(:services) { ['httpd.service'] }

        context 'where the list command succeeds' do
          let(:list_cmd_stderr) { '' }
          let(:list_cmd_exitstatus) { 0 }

          context 'returns no services' do
            before do
              allow(Open3).to receive(:capture2e).and_raise('Should not be called')
            end

            let(:list_cmd_stdout) { '' }

            it 'does not stop services' do
              is_expected.to be_nil

              expect(logger).to have_received(:debug).with('Getting running services')
              expect(Open3).to have_received(:capture3).with('systemctl', 'list-units', '--no-legend', '--type=service,socket', '--state=running', 'httpd.service')
              expect(logger).to have_received(:debug).with('Found running services []')
              expect(logger).not_to have_received(:debug).with('Stopping running services httpd.service')
              expect(Open3).not_to have_received(:capture2e).with('systemctl', 'stop', 'httpd.service')
            end
          end

          context 'returns the service' do
            let(:list_cmd_stdout) { "httpd.service loaded active running The Apache HTTP Server\n" }
            before do
              allow(Open3).to receive(:capture2e).and_return([stop_cmd_output, stop_cmd_status])
              allow(stop_cmd_status).to receive(:success?).and_return(stop_cmd_exitstatus == 0)
            end

            context 'and stop command succeeds' do
              let(:stop_cmd_output) { '' }
              let(:stop_cmd_exitstatus) { 0 }

              it 'it runs successfully' do
                is_expected.to be_nil

                expect(logger).to have_received(:debug).with('Getting running services')
                expect(Open3).to have_received(:capture3).with('systemctl', 'list-units', '--no-legend', '--type=service,socket', '--state=running', 'httpd.service')
                expect(logger).to have_received(:debug).with('Found running services ["httpd.service"]')
                expect(logger).to have_received(:debug).with('Stopping running services httpd.service')
                expect(Open3).to have_received(:capture2e).with('systemctl', 'stop', 'httpd.service')
              end
            end
          end
        end

        context 'where the list command fails' do
          let(:list_cmd_stdout) { '' }
          let(:list_cmd_stderr) { 'Failed StdErr' }
          let(:list_cmd_exitstatus) { 1 }

          before do
            allow(context).to receive(:exit)
          end

          it 'it exits with an error' do
            expect { subject }.to raise_error(RuntimeError, 'called fail_and_exit')

            expect(logger).to have_received(:debug).with('Getting running services')
            expect(Open3).to have_received(:capture3).with('systemctl', 'list-units', '--no-legend', '--type=service,socket', '--state=running', 'httpd.service')
            expect(context).to have_received(:fail_and_exit).with('Failed to get running services: Failed StdErr', 1)
          end
        end
      end
    end
  end
end
