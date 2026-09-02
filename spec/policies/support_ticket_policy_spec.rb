require "rails_helper"

RSpec.describe SupportTicketPolicy do
  let(:product) { Product.create!(name: "Wireless headset", description: "Noise-cancelling headset.", price: 89.99, category: "Accessories") }
  let(:owner) { User.create!(email: "owner@example.com", password: "password", password_confirmation: "password") }
  let(:other_user) { User.create!(email: "other@example.com", password: "password", password_confirmation: "password") }
  let(:admin) { User.create!(email: "admin@example.com", password: "password", password_confirmation: "password", is_admin: true) }
  let(:order) { Order.create!(product: product, user: owner, quantity: 1, payment_method: :cash, unit_price: product.price) }
  let(:support_ticket) { SupportTicket.new(order: order, comment: "The headset will not connect.") }

  it "allows only administrators to list support tickets" do
    expect(described_class.new(admin, SupportTicket).index?).to be(true)
    expect(described_class.new(owner, SupportTicket).index?).to be(false)
  end

  it "allows only the order owner to create a support ticket" do
    expect(described_class.new(owner, support_ticket).create?).to be(true)
    expect(described_class.new(other_user, support_ticket).create?).to be(false)
  end

  it "allows only administrators to view a support ticket" do
    expect(described_class.new(admin, support_ticket).show?).to be(true)
    expect(described_class.new(owner, support_ticket).show?).to be(false)
  end

  it "allows only administrators to close an active support ticket" do
    expect(described_class.new(admin, support_ticket).close?).to be(true)
    expect(described_class.new(owner, support_ticket).close?).to be(false)
  end

  it "allows only the order owner to view a resolution" do
    expect(described_class.new(owner, support_ticket).resolution?).to be(true)
    expect(described_class.new(other_user, support_ticket).resolution?).to be(false)
  end
end
