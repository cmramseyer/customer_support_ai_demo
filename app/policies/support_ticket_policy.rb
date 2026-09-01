class SupportTicketPolicy < ApplicationPolicy
  def index?
    user&.is_admin?
  end

  def create?
    user.present? && record.order.user_id == user.id
  end

  class Scope < Scope
    def resolve
      user&.is_admin? ? scope.all : scope.none
    end
  end
end
