require 'spec_helper'

require_relative '../../util/fake_puppet_file'

describe FakePuppetfile do
  let(:fake) { FakePuppetfile.new }

  specify 'without a version' do
    expect(PuppetForge::Module).not_to receive(:find)

    fake.instance_eval { mod 'theforeman/motd' }

    expect { |b| fake.content(&b) }.to yield_with_args("mod 'theforeman/motd'")
  end

  specify 'with a minimum' do
    expect(PuppetForge::Module).not_to receive(:find)

    fake.instance_eval { mod 'theforeman/motd', '>= 1.2' }

    expect { |b| fake.content(&b) }.to yield_with_args("mod 'theforeman/motd', '>= 1.2'")
  end

  specify 'with a minimum and a maximum' do
    expect(PuppetForge::Module).not_to receive(:find)

    fake.instance_eval { mod 'theforeman/motd', '>= 1.2', '< 3' }

    expect { |b| fake.content(&b) }.to yield_with_args("mod 'theforeman/motd', '>= 1.2', '< 3'")
  end

  specify 'with a git url' do
    expect(PuppetForge::Module).to receive(:find)
      .with('theforeman-motd')
      .and_return(double(PuppetForge::V3::Module, current_release: double(PuppetForge::V3::Release, version: '1.2.3')))

    fake.instance_eval { mod 'theforeman/motd', :git => 'https://github.com/theforeman/puppet-motd' }

    expect { |b| fake.content(&b) }.to yield_with_args("mod 'theforeman/motd', '~> 1.2.3'")
  end
end
