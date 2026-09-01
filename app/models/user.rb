class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable

  has_many :orders, dependent: :restrict_with_error
  has_many :comments, dependent: :destroy
end
