# Simple admin reset
u = User.find_by(login: 'admin')
u.failed_login_count = 0
u.last_failed_login_on = nil
u.password = 'OpenProject2024!'
u.password_confirmation = 'OpenProject2024!'
u.status = 1
u.save(validate: false)

puts "Admin reset complete"
puts "Username: admin"
puts "Password: OpenProject2024!"
puts "Failed logins: #{u.failed_login_count}"
puts "Locked: #{u.locked?}"
