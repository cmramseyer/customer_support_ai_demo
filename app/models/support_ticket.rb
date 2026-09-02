class SupportTicket < ApplicationRecord
  belongs_to :order
  belongs_to :closed_by_user, class_name: "User", optional: true

  enum :status, { active: 0, closed: 1 }, validate: true
  enum :priority, { low: 0, medium: 1, high: 2 }, validate: { allow_nil: true }

  validates :comment, presence: true
  validates :resolution_response, presence: true, if: :closed?
end
