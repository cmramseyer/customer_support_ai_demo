require "rails_helper"

RSpec.describe "Orders", type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password", password_confirmation: "password") }
  let(:product) do
    Product.create!(
      name: "Wireless headset",
      description: "Noise-cancelling headset for customer calls.",
      price: 89.99,
      category: "Accessories"
    )
  end

  before { sign_in(user) }

  it "lists only the current user's orders" do
    own_order = Order.create!(product: product, user: user, quantity: 2, payment_method: :credit_card, unit_price: product.price)
    other_user = User.create!(email: "other@example.com", password: "password", password_confirmation: "password")
    other_product = Product.create!(name: "Desk lamp", description: "Adjustable LED lamp.", price: 29.99, category: "Office")
    Order.create!(product: other_product, user: other_user, quantity: 1, payment_method: :cash, unit_price: other_product.price)

    get orders_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(own_order.product.name, "2 x 89.99 - Credit card", "Orders", "Create Support Ticket", "name=\"support_ticket[comment]\"")
    expect(response.body).not_to include(other_product.name)
  end

  it "shows an empty state when the current user has no orders" do
    get orders_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("No orders yet", "Your purchases will appear here")
  end

  it "shows an Orders link in the authenticated navigation" do
    get products_path

    expect(response.body).to include("href=\"/orders\"", ">Orders</a>")
  end

  it "renders a purchase modal for each product" do
    product

    get products_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Buy", "Payment method", "max=\"99\"")
  end

  it "creates a pending order with the product price snapshot" do
    expect do
      post product_orders_path(product), params: { order: { quantity: 2, payment_method: "credit_card", unit_price: "0", status: "completed" } }
    end.to change(Order, :count).by(1)

    order = Order.last
    expect(response).to redirect_to(product)
    expect(order).to have_attributes(product: product, user: user, quantity: 2, payment_method: "credit_card", unit_price: product.price, status: "pending")

    product.update!(price: 99.99)
    expect(order.reload.unit_price).to eq(89.99)
  end

  it "re-renders the product with errors for invalid purchase data" do
    expect do
      post product_orders_path(product), params: { order: { quantity: 100, payment_method: "" } }
    end.not_to change(Order, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("prevented this order from being created")
  end
end
