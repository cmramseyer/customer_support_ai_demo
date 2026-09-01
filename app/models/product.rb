class Product < ApplicationRecord
  validates :name, :description, :category, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
