require "rails_helper"

RSpec.describe "Sessions", type: :request do
  it "redirects an administrator to support tickets after signing in" do
    admin = User.create!(email: "admin@example.com", password: "password", password_confirmation: "password", is_admin: true)

    post user_session_path, params: { user: { email: admin.email, password: "password" } }

    expect(response).to redirect_to(support_tickets_path)
  end

  it "redirects a regular user to products after signing in" do
    user = User.create!(email: "user@example.com", password: "password", password_confirmation: "password")

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    expect(response).to redirect_to(products_path)
  end
end
