class ProfilesController < ApplicationController
  before_action :authenticate_user!, only: [:show, :update]

  def show
    user = current_user
    user_data = user.slice(:id, :name, :prefecture_id)
    
    if user.photo.attached?
      user_data[:photo_url] = url_for(user.photo.variant(:profile))
    else
      user_data[:photo_url] = nil
    end
    render json: { user: user_data}
  end

  def update
    user = current_user
    if user.update(profile_params)
      user_data = user.slice(:id, :name, :prefecture_id)
      if user.photo.attached?
        user_data[:photo_url] = url_for(user.photo.variant(:profile))
      else
        user_data[:photo_url] = nil
      end
      render status: :ok, json: { user: user_data }
    else
      render status: :unprocessable_content, json: { errors: user.errors.full_messages }
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :prefecture_id,:photo)
  end
end
