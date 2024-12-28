class ApplicationController < ActionController::API
  # Returns the currently logged-in user or nil if not logged in
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Returns true if the user is logged in, false otherwise
  def logged_in?
    current_user.present?
  end

  # Restricts access to routes that require authentication
  def require_login
    unless logged_in?
      render json: { error: "You must be logged in to access this resource" }, status: :unauthorized
    end
  end
end
