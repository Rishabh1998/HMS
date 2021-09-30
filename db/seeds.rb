# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Role.find_or_create_by!(name: "Admin")
# AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password', role_id: 1)

payments = Payment.where(paid_at: nil)
payments.each do |p|
    p.update(paid_at: p.created_at)
end