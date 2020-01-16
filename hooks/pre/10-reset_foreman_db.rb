# See bottom of the script for the command that kicks off the script
require 'English'

def reset_foreman_db
  `which foreman-rake > /dev/null 2>&1`
  if $CHILD_STATUS.success?
    logger.info 'Dropping database!'
    output = `foreman-rake db:drop 2>&1`
    logger.debug output.to_s
    unless $CHILD_STATUS.success?
      logger.warn "Unable to drop DB, ignoring since it's not fatal, output was: '#{output}''"
    end
  else
    logger.warn 'Foreman not installed yet, can not drop database!'
  end
end

reset_foreman_db if app_value(:reset_foreman_db) && !app_value(:noop)
