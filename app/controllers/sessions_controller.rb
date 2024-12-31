class SessionsController < ApplicationController
  # Create the session and log the user in
  def create
    @user = User.find_by(username: params[:username])

    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id  # Store the user's ID in the session
      render json: { message: "Logged in successfully", user: @user.as_json(except: [:password_digest])  }, status: :ok
    else
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end

  # Log the user out
  def destroy
    # session.delete(:user_id)  # Remove the user ID from the session
    reset_session
    render json: { message: "Logged out successfully" }, status: :ok
  end
end
