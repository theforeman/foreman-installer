if param('foreman_proxy_content', 'pulp') && param('foreman_proxy_content', 'pulp').value
  if system("rpm -q katello &>/dev/null")
    fail_and_exit("the pulp node can't be installed on a machine with Katello master", 101)
  end

  if system("(rpm -q ipa-server || rpm -q freeipa-server) &>/dev/null")
    fail_and_exit("the pulp node can't be installed on a machine with IPA", 101)
  end

  unless system("subscription-manager identity &>/dev/null && ! grep -q subscription.rhn.redhat.com /etc/rhsm/rhsm.conf &> /dev/null")
    fail_and_exit("The system has to be registered to a Katello instance before installing the node", 101)
  end
end
