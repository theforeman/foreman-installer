require 'spec_helper'

migration '20240531091300_foreman_proxy_tftp_host_config' do
  scenarios %w[foreman katello foreman-proxy-content] do
    context 'host-config in tftp_dirs missing' do
      let(:answers) do
        {
          'foreman_proxy' => {
            'tftp_root' => '/var/lib/tftpboot',
            'tftp_dirs' => [
              '/var/lib/tftpboot/pxelinux.cfg',
              '/var/lib/tftpboot/grub',
              '/var/lib/tftpboot/grub2',
              '/var/lib/tftpboot/boot',
              '/var/lib/tftpboot/ztp.cfg',
              '/var/lib/tftpboot/poap.cfg',
            ],
          },
        }
      end

      it 'adds bootloader-universe to tftp_dirs' do
        expect(migrated_answers['foreman_proxy']['tftp_dirs']).to include '/var/lib/tftpboot/bootloader-universe'
      end

      it 'adds bootloader-universe/pxegrub2 to tftp_dirs' do
        expect(migrated_answers['foreman_proxy']['tftp_dirs']).to include '/var/lib/tftpboot/bootloader-universe/pxegrub2'
      end

      it 'adds host-config to tftp_dirs' do
        expect(migrated_answers['foreman_proxy']['tftp_dirs']).to include '/var/lib/tftpboot/host-config'
      end
    end

    context 'tftp_dirs empty' do
      let(:answers) do
        {
          'foreman_proxy' => {
            'tftp_root' => '/var/lib/tftpboot',
            'tftp_dirs' => nil,
          },
        }
      end

      it 'keeps tftp_dirs unchanged' do
        expect(migrated_answers['foreman_proxy']['tftp_dirs']).to eq answers['foreman_proxy']['tftp_dirs']
      end
    end
  end
end
