require 'rails_helper'

RSpec.describe "Users::Sessions", type: :request do
  describe "DELETE /users/sign_out" do
    let(:user) {FactoryBot.create(:user)}
    it "ログアウト後は同じJWTで認証できない" do
      post "/users/sign_in",
          params: { user: { email: user.email, password: user.password } },
          as: :json

      expect(response).to have_http_status(:ok)

      token_before_logout = cookies["access_token"]
      expect(token_before_logout).to be_present

      get "/dev/auth_checks", as: :json
      expect(response).to have_http_status(:ok)

      delete "/users/sign_out",as: :json
      expect(response).to have_http_status(:no_content)

      cookies["access_token"] = token_before_logout
      get "/dev/auth_checks", as: :json
      expect(response).to have_http_status(:unauthorized)

    end

  end
end
