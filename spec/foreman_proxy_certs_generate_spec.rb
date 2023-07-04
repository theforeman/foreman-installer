require 'spec_helper'

require 'open3'
require 'tempfile'

Output = Struct.new(:stdout, :stderr, :status) do
  def exitstatus
    status.exitstatus
  end
end

describe 'foreman-proxy-certs-generate' do
  subject { Output.new(*Open3.capture3(*command)) }

  let(:command) { ['bin/foreman-proxy-certs-generate'] + arguments }
  let(:hostname) { 'proxy.example.com' }
  let(:arguments) { ['--no-colors', '--noop', '--foreman-proxy-fqdn', hostname] }

  describe 'without arguments' do
    it do
      is_expected.to have_attributes(
        stdout: "Error during configuration, exiting\n",
        stderr: /Parameter certs-tar invalid:/,
        exitstatus: 21,
      )
    end
  end

  describe 'with valid certs-tar' do
    let(:arguments) { super() + ['--certs-tar', tar_file.path] }
    let(:tar_file) { Tempfile.new }

    after { tar_file.unlink }

    it do
      is_expected.to have_attributes(
        stdout: '',
        stderr: '',
        exitstatus: 0,
      )
    end
  end
end
