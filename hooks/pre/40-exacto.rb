def apply_installer_puppet(manifest)
  bin_path = Kafo::PuppetCommand.search_puppet_path('puppet')
  command = "echo \"#{manifest}\" | #{bin_path} apply --detailed-exitcodes --modulepath=/usr/share/foreman-installer/modules"

  stdout, stderr, status = Open3.capture3(*Kafo::PuppetCommand.format_command(command))
  if status != 1
    puts stdout
  else
    puts stderr
  end
end

generate_manifest = <<~MANIFEST
  class { 'certs::generate':
    foreman => true,
    apache => true,
    candlepin => true,
    foreman_proxy => true,
  }
MANIFEST

apply_installer_puppet(generate_manifest)

system('dnf -y install ansible-core git-core podman python3-cryptography python3-libsemanage python3-requests bash-completion nmap python3.12-psycopg2 python3.12-requests')

Dir.chdir('/opt') do
  system('git clone https://github.com/theforeman/foreman-quadlet')
end

Dir.chdir('/opt/foreman-quadlet') do
  system('git checkout installer-certs')
  system('ansible-galaxy install -r requirements.yml')
  status = system('ansible-playbook playbooks/deploy.yaml -e certificate_source=installer')
end
