class Order < ApplicationRecord
  belongs_to :product
  belongs_to :user
  has_many :support_tickets, dependent: :restrict_with_error

  enum :status, { pending: 0, completed: 1 }, validate: true
  enum :payment_method, { cash: "cash", credit_card: "credit_card", gift_card: "gift_card" }, validate: true

  validates :quantity, numericality: { only_integer: true, in: 1..99 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
end
