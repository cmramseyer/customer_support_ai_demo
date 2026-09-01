require "rails_helper"

RSpec.describe Product do
  subject(:product) do
    described_class.new(
      name: "Wireless headset",
      description: "Noise-cancelling headset for customer calls.",
      price: 89.99,
      category: "Accessories"
    )
  end

  it "is valid with all required attributes" do
    expect(product).to be_valid
  end

  %i[name description category].each do |attribute|
    it "requires a #{attribute}" do
      product.public_send("#{attribute}=", nil)

      expect(product).not_to be_valid
      expect(product.errors[attribute]).to include("can't be blank")
    end
  end

  it "rejects a negative price" do
    product.price = -0.01

    expect(product).not_to be_valid
    expect(product.errors[:price]).to include("must be greater than or equal to 0")
  end
end
