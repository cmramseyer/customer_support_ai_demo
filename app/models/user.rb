class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable

  has_many :orders, dependent: :restrict_with_error
  has_many :comments, dependent: :destroy

  validates :is_admin, inclusion: { in: [ true, false ] }
end
