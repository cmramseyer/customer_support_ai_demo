# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
[
  "john@demo.com",
  "susan@demo.com"
].each do |email|
  user = User.find_or_initialize_by(email: email)
  user.update!(password: "demodemo", password_confirmation: "demodemo")
end

admin = User.find_or_initialize_by(email: "admin@demo.com")
admin.update!(password: "demodemo", password_confirmation: "demodemo", is_admin: true)
