class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def after_sign_in_path_for(resource)
    resource.is_admin? ? support_tickets_path : products_path
  end

  def user_not_authorized
    respond_to do |format|
      format.html { redirect_to products_path, alert: "You are not authorized to perform this action." }
      format.json { head :forbidden }
    end
  end
end
