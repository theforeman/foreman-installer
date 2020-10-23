def remove_user_from_group(user, group)
  begin
    is_member = Etc.getgrnam(group).mem.include?(user)
  rescue ArgumentError
    is_member = false
  end
  if is_member
    execute!("gpasswd -d '#{user}' '#{group}'")
  else
    true
  end
end

remove_user_from_group('apache', 'foreman')
