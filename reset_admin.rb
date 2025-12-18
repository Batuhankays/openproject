u = User.find_by(login: 'admin')
u.failed_login_count = 0
u.last_failed_login_on = nil
u.password = 'admin123!'
u.password_confirmation = 'admin123!'
u.save(validate: false)
puts "Admin account unlocked and password reset to: admin123!"
