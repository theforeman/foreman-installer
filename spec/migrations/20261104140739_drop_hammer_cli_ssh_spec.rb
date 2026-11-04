require 'spec_helper'

migration '20261104140739_drop_hammer_cli_ssh' do
  scenarios %w[foreman katello] do
    context 'when hammer CLI SSH is enabled' do
      let(:answers) do
        {
          'foreman::cli::ssh' => true,
        }
      end

      it 'removes the obsolete answer' do
        expect(migrated_answers).not_to include('foreman::cli::ssh')
      end
    end
  end
end
