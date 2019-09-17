require 'spec_helper'
require 'open3'

# certs/ca were generated with https://github.com/iNecas/ownca
# badkey passphrase is 'foreman'

describe 'katello-certs-check' do
  let(:command) { File.join(__dir__, '..', 'bin', 'katello-certs-check') }
  let(:directory) { File.join(FIXTURE_DIR, 'katello-certs-check') }
  let(:ca) { File.join(directory, 'cacert.crt') }
  let(:key) { File.join(directory, 'foreman.example.com.key') }
  let(:cert) { File.join(directory, 'foreman.example.com.crt') }
  let(:badkey) { File.join(directory, 'key_pass.key') }

  def fixture(filename)
    File.read(File.join(directory, filename)).gsub('|COMMAND|', command)
  end

  it 'without parameters' do
    stdout, stderr, status = Open3.capture3(command)
    expect(stderr).to eq fixture('missing-parameter.txt')
    expect(stdout).to eq ''
    expect(status.exitstatus).to eq 1
  end

  it 'completes correctly' do
    command_with_certs = "#{command} -b #{ca} -k #{key} -c #{cert}"
    stdout, stderr, status = Open3.capture3(command_with_certs)
    expect(stderr).to eq ''
    expect(status.exitstatus).to eq 0
  end

  it 'with password on key' do
    command_with_certs = "#{command} -b #{ca} -k #{badkey} -c #{cert}"
    stdout, stderr, status = Open3.capture3(command_with_certs)
    expect(stderr).to eq "The #{badkey} contains a passphrase, remove the key's passphrase by doing: \nmv #{badkey} #{badkey}.old \nopenssl rsa -in #{badkey}.old -out #{badkey}\n"
    expect(status.exitstatus).to eq 1
  end
end
