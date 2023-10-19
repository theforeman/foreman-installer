require 'json'
require 'semantic_puppet'

SUPPORTED_PUPPET_VERSIONS = ['7.9.0'].map { |v| SemanticPuppet::Version.parse(v) }

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

      SUPPORTED_PUPPET_VERSIONS.each do |puppet_version|
        it "supports Puppet #{puppet_version}" do
          expect(puppet_requirement).to include(puppet_version)
        end
      end
    end
  end
end
