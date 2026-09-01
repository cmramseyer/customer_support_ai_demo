require "rails_helper"

RSpec.describe Order do
  let(:product) { Product.create!(name: "Wireless headset", description: "Noise-cancelling headset.", price: 89.99, category: "Accessories") }
  let(:user) { User.create!(email: "user@example.com", password: "password", password_confirmation: "password") }

  subject(:order) do
    described_class.new(product: product, user: user, quantity: 2, payment_method: :credit_card, unit_price: product.price)
  end

  it "is valid with required purchase data" do
    expect(order).to be_valid
  end

  it "defaults to pending" do
    expect(order.status).to eq("pending")
  end

  it "requires a quantity from 1 through 99" do
    order.quantity = 0
    expect(order).not_to be_valid

    order.quantity = 100
    expect(order).not_to be_valid
  end

  it "rejects an unsupported payment method" do
    order.payment_method = :bank_transfer

    expect(order).not_to be_valid
    expect(order.errors[:payment_method]).to include("is not included in the list")
  end

  it "supports pending and completed statuses" do
    expect(order).to be_pending

    order.completed!

    expect(order).to be_completed
  end

  it "prevents deleting a product with purchase history" do
    order.save!

    expect(product.destroy).to be(false)
    expect(product.errors[:base]).to include("Cannot delete record because dependent orders exist")
  end
end
