FPC = 'foreman_proxy_content'.freeze
MEDIA_ROOT = 'pulpcore_media_root'.freeze

def upgrade
  answers[FPC] = {} unless answers[FPC].is_a?(Hash)
  answers[FPC][MEDIA_ROOT] = '/var/lib/pulp/docroot'
end

upgrade if answers[FPC] && answers[FPC][MEDIA_ROOT].nil?

