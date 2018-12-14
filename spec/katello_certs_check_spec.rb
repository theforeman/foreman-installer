require 'spec_helper'
require 'open3'

describe 'katello-certs-check' do
  let(:command) { File.join(__dir__, '..', 'bin', 'katello-certs-check') }
  let(:directory) { File.join(FIXTURE_DIR, 'katello-certs-check') }

  def fixture(filename)
    File.read(File.join(directory, filename)).gsub('|COMMAND|', command)
  end

  it 'without parameters' do
    stdout, stderr, status = Open3.capture3(command)
    expect(stderr).to eq fixture('missing-parameter.txt')
    expect(stdout).to eq ''
    expect(status.exitstatus).to eq 1
  end
end
