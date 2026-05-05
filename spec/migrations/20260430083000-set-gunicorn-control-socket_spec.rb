require 'spec_helper'

migration '20260430083000-set-gunicorn-control-socket' do
  scenarios %w[katello foreman-proxy-content] do
    context 'when foreman_proxy_content is true (modern katello default)' do
      let(:answers) { { 'foreman_proxy_content' => true } }

      it 'sets the api control socket path' do
        expect(migrated_answers['foreman_proxy_content']['pulpcore_api_control_socket_path'])
          .to eq('/run/pulpcore-api/gunicorn.ctl')
      end

      it 'sets the content control socket path' do
        expect(migrated_answers['foreman_proxy_content']['pulpcore_content_control_socket_path'])
          .to eq('/run/pulpcore-content/gunicorn.ctl')
      end
    end

    context 'without existing socket path answers' do
      let(:answers) { { 'foreman_proxy_content' => {} } }

      it 'sets the api control socket path' do
        expect(migrated_answers['foreman_proxy_content']['pulpcore_api_control_socket_path'])
          .to eq('/run/pulpcore-api/gunicorn.ctl')
      end

      it 'sets the content control socket path' do
        expect(migrated_answers['foreman_proxy_content']['pulpcore_content_control_socket_path'])
          .to eq('/run/pulpcore-content/gunicorn.ctl')
      end
    end

    context 'with existing custom socket paths' do
      let(:answers) do
        {
          'foreman_proxy_content' => {
            'pulpcore_api_control_socket_path' => '/custom/api.ctl',
            'pulpcore_content_control_socket_path' => '/custom/content.ctl',
          },
        }
      end

      it 'preserves a custom api socket path' do
        expect(migrated_answers['foreman_proxy_content']['pulpcore_api_control_socket_path'])
          .to eq('/custom/api.ctl')
      end

      it 'preserves a custom content socket path' do
        expect(migrated_answers['foreman_proxy_content']['pulpcore_content_control_socket_path'])
          .to eq('/custom/content.ctl')
      end
    end
  end
end
