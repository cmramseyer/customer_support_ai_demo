class Product < ApplicationRecord
  has_many :orders, dependent: :restrict_with_error
  has_many :comments, dependent: :destroy

  validates :name, :description, :category, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
