require 'json'
require 'semantic_puppet'

describe 'Puppet module' do
  VERSIONS = ['5.5.10', '6.0.0'].map { |v| SemanticPuppet::Version.parse(v) }
  DISTROS = {
    'CentOS' => ['7', '8'],
    'Debian' => ['10'],
    'RedHat' => ['7', '8'],
    'Ubuntu' => ['18.04'],
  }

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

      VERSIONS.each do |puppet_version|
        it "should support Puppet #{puppet_version}" do
          expect(puppet_requirement).to include(puppet_version)
        end
      end

      DISTROS.each do |distro, versions|
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
