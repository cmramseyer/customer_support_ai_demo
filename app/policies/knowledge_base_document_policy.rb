class KnowledgeBaseDocumentPolicy < ApplicationPolicy
  def index?
    user&.is_admin?
  end

  def new?
    user&.is_admin?
  end

  def create?
    user&.is_admin?
  end

  class Scope < Scope
    def resolve
      user&.is_admin? ? scope.all : scope.none
    end
  end
end
