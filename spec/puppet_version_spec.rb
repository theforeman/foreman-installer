require 'json'
require 'semantic_puppet'

SUPPORTED_PUPPET_VERSIONS = ['7.9.0', '8.0.0'].map { |v| SemanticPuppet::Version.parse(v) }
SUPPORTED_DISTROS = {
  'CentOS' => ['8', '9'],
  'Debian' => ['11'],
  'RedHat' => ['8', '9'],
  'Ubuntu' => ['20.04'],
}

describe 'Puppet module' do
  Dir.glob(File.join(__dir__, '../_build/modules/*/metadata.json')).each do |filename|
    context File.basename(File.dirname(filename)) do
      let(:metadata) { JSON.parse(File.read(filename)) }
      let(:requirements) { metadata['requirements'] || [] }
      let(:puppet_requirement) do
        requirement = requirements.find { |req| req['name'] == 'puppet' }
        version_requirement = requirement['version_requirement'] if requirement
        version_requirement ||= '>= 0'
        SemanticPuppet::VersionRange.parse(version_requirement)
      end
      let(:operatingsystem_support) { metadata['operatingsystem_support'] }

      SUPPORTED_PUPPET_VERSIONS.each do |puppet_version|
        it "supports Puppet #{puppet_version}" do
          expect(puppet_requirement).to include(puppet_version)
        end
      end

      SUPPORTED_DISTROS.each do |distro, versions|
        versions.each do |version|
          it "should support #{distro} #{version}" do
            if operatingsystem_support.nil?
              skip "No OS support listed"
            end

            distro_versions = operatingsystem_support.find { |os| os['operatingsystem'] == distro }

            if distro_versions.nil?
              skip "Distribution #{distro} is not supported"
            end

            unless distro_versions.key?('operatingsystemrelease')
              skip "No specific distribution versions listed"
            end

            expect(distro_versions['operatingsystemrelease']).to include(version)
          end
        end
      end
    end
  end
end
