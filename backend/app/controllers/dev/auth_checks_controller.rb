class Dev::AuthChecksController < ApplicationController
  before_action :authenticate_user!
  def show
    render status: :ok, json: { message:"認証できました。", user_id: current_user.id }
  end
end
