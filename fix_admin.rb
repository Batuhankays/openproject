# Completely disable account locking and reset admin
u = User.find_by(login: 'admin')

# Reset all lockout fields
u.failed_login_count = 0
u.last_failed_login_on = nil

# Reset password
u.password = 'admin123!'
u.password_confirmation = 'admin123!'

# Force active status
u.status = 1

# Save without validations
u.save(validate: false)

# Disable failed login tracking globally
Setting.set_from_params('brute_force_block_after_failed_logins', '0')
Setting.set_from_params('brute_force_block_minutes', '0')

puts "=" * 50
puts "Admin account fully reset:"
puts "  - Failed logins: #{u.failed_login_count}"
puts "  - Last failed: #{u.last_failed_login_on}"
puts "  - Status: #{u.status}"
puts "  - Login enabled: #{!u.locked?}"
puts "  - Password: admin123!"
puts "=" * 50
puts "Brute force protection: DISABLED"
puts "=" * 50
