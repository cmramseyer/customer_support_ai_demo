require "rails_helper"

RSpec.describe SupportTicket do
  let(:product) { Product.create!(name: "Wireless headset", description: "Noise-cancelling headset.", price: 89.99, category: "Accessories") }
  let(:user) { User.create!(email: "user@example.com", password: "password", password_confirmation: "password") }
  let(:order) { Order.create!(product: product, user: user, quantity: 2, payment_method: :credit_card, unit_price: product.price) }

  subject(:support_ticket) { described_class.new(order: order, comment: "The headset will not connect.") }

  it "is active by default" do
    expect(support_ticket).to be_active
  end

  it "requires a comment" do
    support_ticket.comment = ""

    expect(support_ticket).not_to be_valid
    expect(support_ticket.errors[:comment]).to include("can't be blank")
  end

  it "supports active and closed statuses" do
    support_ticket.resolution_response = "A replacement headset has been shipped."
    support_ticket.closed!

    expect(support_ticket).to be_closed
  end

  it "requires a resolution response when closed" do
    support_ticket.status = :closed

    expect(support_ticket).not_to be_valid
    expect(support_ticket.errors[:resolution_response]).to include("can't be blank")
  end

  it "supports an optional priority" do
    expect(support_ticket.priority).to be_nil
    expect(support_ticket).to be_valid

    support_ticket.priority = :high
    expect(support_ticket).to be_valid
    expect(support_ticket).to be_high
  end

  it "persists related ticket IDs" do
    support_ticket.related_tickets = [ 12, 34 ]
    support_ticket.save!

    expect(support_ticket.reload.related_tickets).to eq([ 12, 34 ])
  end
end
