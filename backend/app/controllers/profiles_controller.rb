class ProfilesController < ApplicationController
  before_action :authenticate_user!, only: :show

  def show
    render json: { user: current_user.slice(:id, :email, :name, :prefecture_id) }
  end
end
