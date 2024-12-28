class UsersController < ApplicationController
  # Allow creating new users
  def create
    @user = User.new(user_params)

    if @user.save
      # Automatically log the user in after registration
      session[:user_id] = @user.id
      render json: { message: "User created and logged in successfully" }, status: :created
    else
      render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if logged_in? && current_user.update(user_params)
      render json: { message: "User updated successfully" }, status: :ok
    else
      render json: { error: "Failed to update user" }, status: :unprocessable_entity
    end
  end

  def destroy
    if logged_in? && current_user.destroy
      session[:user_id] = nil  # Log out the user after deleting
      render json: { message: "User deleted successfully" }, status: :ok
    else
      render json: { error: "Failed to delete user" }, status: :unprocessable_entity
    end
  end

  def get_current_user
    if logged_in?
      render json: current_user
    else
      render json: { error: "Not logged in" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end