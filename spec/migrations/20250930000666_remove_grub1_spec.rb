require 'spec_helper'

migration '20250930000666_remove_grub1' do
  scenarios %w[foreman] do
    context 'tftp_dirs' do
      let(:answers) do
        {
          'foreman_proxy' => {
            'tftp_root' => '/var/lib/tftpboot',
            'tftp_dirs' => [
              '/var/lib/tftpboot/pxelinux.cfg',
              '/var/lib/tftpboot/grub',
              '/var/lib/tftpboot/grub2',
            ],
          },
        }
      end

      it 'remove grub1' do
        expect(migrated_answers['foreman_proxy']['tftp_dirs']).not_to include("/var/lib/tftpboot/grub")
      end

      it 'keep grub2' do
        expect(migrated_answers['foreman_proxy']['tftp_dirs']).to include("/var/lib/tftpboot/grub2")
      end
    end
  end
end
