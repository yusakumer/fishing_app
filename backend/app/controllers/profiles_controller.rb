class ProfilesController < ApplicationController
  before_action :authenticate_user!, only: [:show, :update]

  def show
    render json: { user: current_user.slice(:id, :email, :name, :prefecture_id) }
  end

  def update
    user = current_user
    if user.update(profile_params)
      render status: :ok, json: { user: user.slice(:id, :email, :name, :prefecture_id) }
    else
      render status: :unprocessable_content, json: { errors: user.errors.full_messages }
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :prefecture_id)
  end
end
