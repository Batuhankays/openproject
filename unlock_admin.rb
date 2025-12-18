u = User.find_by(login: 'admin')
u.failed_login_count = 0
u.last_failed_login_on = nil
u.save(validate: false)
puts "Admin account unlocked successfully!"
