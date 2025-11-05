require 'spec_helper'

migration '20250317000666_remove_ovirt' do
  scenarios %w[foreman katello] do
    context 'foreman::compute::ovirt was enabled' do
      let(:answers) do
        {
          'foreman::compute::ovirt' => { 'version' => 'installed' },
        }
      end

      it 'remove compute resource ovirt' do
        expect(migrated_answers).not_to(include("foreman::compute::ovirt"))
      end

      it 'add plugin ovirt' do
        expect(migrated_answers["foreman::plugin::ovirt"]).to be true
      end
    end

    context 'foreman::compute::ovirt was disabled' do
      let(:answers) do
        {
          'foreman::compute::ovirt' => false,
        }
      end

      it 'remove compute resource ovirt' do
        expect(migrated_answers).not_to(include("foreman::compute::ovirt"))
      end

      it 'does not add plugin ovirt' do
        expect(migrated_answers["foreman::plugin::ovirt"]).to be false
      end
    end
  end
end
