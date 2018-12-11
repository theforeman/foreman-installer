# See bottom of the script for the command that kicks off the script

def clear_pulp_content
  if File.directory?('/var/lib/pulp/content')
    `rm -rf /var/lib/pulp/content/*`
    `mongo pulp_database --eval 'db.repo_importers.update({"scratchpad": {$ne: null}}, {$set: {"scratchpad.repomd_revision": null}}, {"multi":true})'`
    logger.info 'Pulp content successfully removed.'
  else
    logger.warn 'Pulp content directory not present at \'/var/lib/pulp/content\''
  end
end

clear_pulp_content if app_value(:clear_pulp_content) && !app_value(:noop)
