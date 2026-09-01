require 'rails_helper'

RSpec.describe User, type: :model do
  it "authenticates with an email and password" do
    user = described_class.new(email: "user@example.com", password: "password", password_confirmation: "password")

    expect(user).to be_valid
  end

  it "does not include password recovery" do
    expect(described_class.devise_modules).not_to include(:recoverable)
  end

  it "is not an administrator by default" do
    user = described_class.new(email: "user@example.com", password: "password", password_confirmation: "password")

    expect(user).not_to be_is_admin
  end
end
