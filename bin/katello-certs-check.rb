#!/usr/bin/env ruby
require 'openssl'
require 'optparse'

class FailedCheck < Exception
end

def check(message, code=1)
  # TODO: no line end
  puts message
  begin
    result = yield
  rescue FailedCheck => e
    # TODO: fail in a cleaner way
    $stderr.puts e
    exit code
  rescue Exception => e
    # TODO: fail in a cleaner way
    fail "Failed: #{e}"
    exit code
  else
    # TODO markup
    puts "[OK]"
  end
  result
end

cert_path = nil
key_path = nil
bundle_path = nil

parser = OptionParser.new do |opts|
  opts.on('-t [SERVER|PROXY]', String, 'Target') do |v|
    # TODO store?
  end

  opts.on('-c [CERTIFICATE]', String, 'Path to certificate file') do |path|
    unless File.exist?(path)
      fail "Path '#{path}' does not exist"
    end
    cert_path = path
  end

  opts.on('-k [KEY]', String, 'Path to private key file') do |path|
    unless File.exist?(path)
      fail "Path '#{path}' does not exist"
    end
    key_path = path
  end

  opts.on('-b [BUNDLE]', String, 'Path to Certificate Authority bundle file') do |path|
    unless File.exist?(path)
      fail "Path '#{path}' does not exist"
    end
    bundle_path = path
  end
end

parser.parse!

if [cert_path, key_path, bundle_path].include?(nil)
  # TODO: print usage
  fail "Missing cert, key or bundle option"
end

cert = check("Reading certificate file '#{cert_path}'") do
  OpenSSL::X509::Certificate.new(File.read(cert_path))
rescue Exception => e
  raise FailedCheck, "Failed to read certificate: #{e}"
  # TODO: check if file is DER encoded
end

key = check("Reading private key '#{key_path}'") do
  OpenSSL::PKey.read(File.read(key_path))
rescue Exception => e
  # TODO: check if there's a password?
  raise FailedCheck, "Failed to read private key: #{e}"
end

bundle = check("Reading CA certificate '#{bundle_path}'") do
  OpenSSL::X509::Certificate.new(File.read(bundle_path))
rescue Exception => e
  raise FailedCheck, "Failed to read CA certificate: #{e}"
end

check('Checking certificate expiration') do
  now = Time.now
  if cert.not_before > now
    raise FailedCheck, "Certificate not valid yet: #{cert.not_before} is in the future"
  end

  if cert.not_after < now
    raise FailedCheck, "Certificate no longer valid: #{cert.not_after} is in the past"
  end
end

check('Checking CA bundle expiration') do
  now = Time.now
  if bundle.not_before > now
    raise FailedCheck, "Certificate not valid yet: #{bundle.not_before} is in the future"
  end

  if bundle.not_after < now
    raise FailedCheck, "Certificate no longer valid: #{bundle.not_after} is in the past"
  end
end

check('Verifying if private key matches certificate') do
  unless cert.check_private_key(key)
    raise FailedCheck, "Certificate '#{cert_path}' is not signed by '#{key_path}"
  end
end

store = OpenSSL::X509::Store.new
# TODO: also for clients?
store.purpose = OpenSSL::X509::PURPOSE_SSL_SERVER
store.add_file(bundle_path)

chain = check('Verify certificate is singed by bundle') do
  unless store.verify(cert)
    raise FailedCheck, "Certificate is not signed by bundle: #{store.error_string}"
  end
  store.chain
end

# TODO
check('Verifying root is included in bundle has CA:TRUE') do
  # TODO: oid for basicConstraints?
  basicConstraints = chain.last.extensions.find { |ext| ext.oid == 'basicConstraints' }
  unless basicConstraints
    raise FailedCheck, 'No basicConstraints extension on root'
  end

  unless basicConstraints.value == 'CA:TRUE'
    raise FailedCheck, "basicConstraints extension has value '#{basicConstraints.value}' instead of CA:TRUE"
  end
end

# TODO: check if there aren't more than 32 certs in the store
# TODO: verify if there aren't TRUSTED certificates in the store

check('Verifying if subjectAltName extension is valid') do
  # TODO oid for subjectAltName?
  subjectAltName = cert.extensions.find { |ext| ext.oid == 'subjectAltName' }
  unless subjectAltName
    # Common Name is deprecated, use Subject Alt Name instead. See: https://tools.ietf.org/html/rfc2818#section-3.1"
    raise FailedCheck, 'No subjectAltName extension on certificate'
  end

  cn = cert.subject.to_a.find { |name, _data, _type| name == 'CN' }
  unless cn
    raise FailedCheck, 'Unable to determine CN on certificate'
  end
  cn_value = cn[1]
  unless cn_value.include?('.')
    raise FailedCheck, "commonName on #{cert_path} is set to a shortname while an FQDN is expected"
  end

  unless subjectAltName.value.include?("DNS:#{cn_value}")
    raise FailedCheck, "subjectAltName on certificate doesn't include commonName '#{cn_value}'"
  end
end

# TODO: check key usage includes Key Encipherment on cert
