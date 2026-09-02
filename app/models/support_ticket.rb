class SupportTicket < ApplicationRecord
  belongs_to :order

  enum :status, { active: 0, closed: 1 }, validate: true
  enum :priority, { low: 0, medium: 1, high: 2 }, validate: { allow_nil: true }

  validates :comment, presence: true
end
