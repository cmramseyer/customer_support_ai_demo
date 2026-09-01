require "rails_helper"

RSpec.describe "Products", type: :request do
  let!(:product) do
    Product.create!(
      name: "Wireless headset",
      description: "Noise-cancelling headset for customer calls.",
      price: 89.99,
      category: "Accessories"
    )
  end

  let(:product_params) do
    {
      name: "Desk lamp",
      description: "Adjustable LED lamp.",
      price: "29.99",
      category: "Office"
    }
  end

  it "lists products" do
    get products_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(product.name)
  end

  it "creates a product" do
    expect do
      post products_path, params: { product: product_params }
    end.to change(Product, :count).by(1)

    expect(response).to redirect_to(Product.last)
  end

  it "updates a product" do
    patch product_path(product), params: { product: product_params }

    expect(response).to redirect_to(product)
    expect(product.reload).to have_attributes(name: "Desk lamp", category: "Office")
  end

  it "deletes a product" do
    expect do
      delete product_path(product)
    end.to change(Product, :count).by(-1)

    expect(response).to redirect_to(products_path)
  end
end
