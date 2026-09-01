class SupportTicket < ApplicationRecord
  belongs_to :order

  enum :status, { active: 0, closed: 1 }, validate: true

  validates :comment, presence: true
end
