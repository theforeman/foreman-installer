require 'spec_helper'
require 'open3'

# certs/ca were generated with https://github.com/iNecas/ownca
# badkey passphrase is 'foreman'

describe 'katello-certs-check' do
  def fixture(filename)
    File.read(File.join(directory, filename)).gsub('|COMMAND|', command)
  end

  let(:command) { File.join(__dir__, '..', 'bin', 'katello-certs-check') }
  let(:directory) { File.join(FIXTURE_DIR, 'katello-certs-check') }
  let(:certs_directory) { File.join(directory, 'certs') }
  let(:ca) { File.join(certs_directory, 'ca-bundle.crt') }

  context 'with valid certificates' do
    let(:key) { File.join(certs_directory, 'foreman.example.com.key') }
    let(:cert) { File.join(certs_directory, 'foreman.example.com.crt') }
    let(:badkey) { File.join(directory, 'key_pass.key') }

    it 'without parameters' do
      stdout, stderr, status = Open3.capture3(command)
      expect(stderr).to eq fixture('missing-parameter.txt')
      expect(stdout).to eq ''
      expect(status.exitstatus).to eq 1
    end

    it 'completes correctly' do
      command_with_certs = "#{command} -b #{ca} -k #{key} -c #{cert}"
      _stdout, stderr, status = Open3.capture3(command_with_certs)
      expect(stderr).to eq ''
      expect(status.exitstatus).to eq 0
    end

    it 'with password on key' do
      command_with_certs = "#{command} -b #{ca} -k #{badkey} -c #{cert}"
      _stdout, stderr, status = Open3.capture3(command_with_certs)
      expect(stderr).to eq "The #{badkey} contains a passphrase, remove the key's passphrase by doing: \nmv #{badkey} #{badkey}.old \nopenssl pkey -in #{badkey}.old -out #{badkey}\n"
      expect(status.exitstatus).to eq 1
    end
  end

  context 'with valid ECC certificates' do
    let(:key) { File.join(certs_directory, 'foreman-ec384.example.com.key') }
    let(:cert) { File.join(certs_directory, 'foreman-ec384.example.com.crt') }
    let(:badkey) { File.join(directory, 'key_pass.key') }

    it 'completes correctly' do
      command_with_certs = "#{command} -b #{ca} -k #{key} -c #{cert}"
      _stdout, stderr, status = Open3.capture3(command_with_certs)
      expect(stderr).to eq ''
      expect(status.exitstatus).to eq 0
    end

    it 'with password on key' do
      command_with_certs = "#{command} -b #{ca} -k #{badkey} -c #{cert}"
      _stdout, stderr, status = Open3.capture3(command_with_certs)
      expect(stderr).to eq "The #{badkey} contains a passphrase, remove the key's passphrase by doing: \nmv #{badkey} #{badkey}.old \nopenssl pkey -in #{badkey}.old -out #{badkey}\n"
      expect(status.exitstatus).to eq 1
    end
  end

  context 'with invalid server certificates' do
    let(:key) { File.join(certs_directory, 'invalid.key') }
    let(:cert) { File.join(certs_directory, 'invalid.crt') }

    it 'fails if purpose is not sslserver' do
      command_with_certs = "#{command} -b #{ca} -k #{key} -c #{cert}"
      _stdout, stderr, status = Open3.capture3(command_with_certs)
      expect(stderr).to include 'does not verify'
      expect(status.exitstatus).to eq 15 # the code for invalid is 4, but the cert is also failing the SAN check, making it 15
    end
  end

  context 'with invalid SAN server certificates' do
    let(:key) { File.join(certs_directory, 'foreman-bad-san.example.com.key') }
    let(:cert) { File.join(certs_directory, 'foreman-bad-san.example.com.crt') }

    it 'fails if purpose is not sslserver' do
      command_with_certs = "#{command} -b #{ca} -k #{key} -c #{cert}"
      _stdout, stderr, status = Open3.capture3(command_with_certs)
      expect(stderr).to include 'does not have a Subject Alt Name matching the Subject CN'
      expect(status.exitstatus).to eq 11
    end
  end

  context 'with wildcard certificate' do
    let(:key) { File.join(certs_directory, 'wildcard.key') }
    let(:cert) { File.join(certs_directory, 'wildcard.crt') }

    it 'completes correctly' do
      command_with_certs = "#{command} -b #{ca} -k #{key} -c #{cert}"
      stdout, stderr, status = Open3.capture3(command_with_certs)
      expect(stderr).to eq ''
      expect(stdout).to include 'Checking CA bundle size: 2'
      expect(status.exitstatus).to eq 0
    end
  end

  context 'with shortname certificate' do
    let(:key) { File.join(certs_directory, 'shortname.key') }
    let(:cert) { File.join(certs_directory, 'shortname.crt') }

    it 'fails on shortname' do
      command_with_certs = "#{command} -b #{ca} -k #{key} -c #{cert}"
      _stdout, stderr, status = Open3.capture3(command_with_certs)
      expect(stderr).to include 'The shortname.crt is using a shortname for Common Name (CN) and cannot be used with Katello.'
      expect(stderr).to include 'The shortname.crt is using only shortnames for Subject Alt Name and cannot be used with Katello.'
      expect(status.exitstatus).to eq 1
    end
  end

  context 'with bundle containing trust rules' do
    let(:key) { File.join(certs_directory, 'foreman.example.com.key') }
    let(:cert) { File.join(certs_directory, 'foreman.example.com.crt') }
    let(:ca) { File.join(certs_directory, 'ca-bundle-with-trust-rules.crt') }

    it 'fails on bundle validation' do
      command_with_certs = "#{command} -b #{ca} -k #{key} -c #{cert}"
      _stdout, stderr, status = Open3.capture3(command_with_certs)
      expect(stderr).to include 'The CA bundle contains 1 certificate(s) with trust rules. This may create problems for older systems to trust the bundle. Please, recreate the bundle using certificates without trust rules'
      expect(status.exitstatus).to eq 10
    end
  end

  context 'with sha1 server CA certificate' do
    let(:key) { File.join(certs_directory, 'foreman-sha1.example.com.key') }
    let(:cert) { File.join(certs_directory, 'foreman-sha1.example.com.crt') }
    let(:ca) { File.join(certs_directory, 'ca-sha1.crt') }

    it 'fails' do
      command_with_certs = "#{command} -b #{ca} -k #{key} -c #{cert}"
      _stdout, stderr, status = Open3.capture3(command_with_certs)
      expect(stderr).to include "The file '#{ca}' contains a certificate signed with sha1 and will break installation. Update the server CA certificate and its chain with one signed by sha256 or stronger."
      expect(status.exitstatus).to eq 4
    end
  end

  context 'with sha1 server CA certificate bundle' do
    let(:key) { File.join(certs_directory, 'foreman-sha1.example.com.key') }
    let(:cert) { File.join(certs_directory, 'foreman-sha1.example.com.crt') }
    let(:ca) { File.join(certs_directory, 'ca-sha1-bundle.crt') }

    it 'fails' do
      command_with_certs = "#{command} -b #{ca} -k #{key} -c #{cert}"
      _stdout, stderr, status = Open3.capture3(command_with_certs)
      expect(stderr).to include "The file '#{ca}' contains a certificate signed with sha1 and will break installation. Update the server CA certificate and its chain with one signed by sha256 or stronger."
      expect(status.exitstatus).to eq 4
    end
  end
end
