require 'rails_helper'
require 'time'

RSpec.describe "Users::Registrations", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  describe "POST /users" do
    let(:prefecture) { FactoryBot.create(:prefecture) }

    context "入力が正しい場合" do
      let(:user_params) do
        FactoryBot.attributes_for(:user).merge(
          prefecture_id: prefecture.id
        )
      end

      it "ユーザーが登録できる" do
        expect {
          post "/users" , params: {user: user_params}, as: :json 
        }.to change(User, :count).by(1)
        expect(response.status).to eq(201)
      end

      it "登録時にCookieの有効期限を1日後に設定する" do
        freeze_time do
          post "/users", params: { user: user_params }, as: :json
          expect(response).to have_http_status(:created)

          # 次のリクエストを送る前に、Cookieの期限をレスポンスから取り出す。
          cookie_headers = Array(response.headers["Set-Cookie"])
          access_token_cookie = cookie_headers.find do |header|
            header.start_with?("access_token=")
          end
          puts cookie_headers
          puts access_token_cookie
          expect(access_token_cookie).to be_present

          expires_text = access_token_cookie[/expires=([^;]+)/i, 1]
          expect(expires_text).to be_present

          # HTTPの日付文字列を時刻へ変換し、1日後と一致するか確認する。
          expect(Time.httpdate(expires_text)).to eq(1.day.from_now)
        end
      end

      it "登録直後にログイン操作なしで本人として認証できる" do
        post "/users", params: {user: user_params }, as: :json
        expect(cookies["access_token"]).to be_present
        get "/dev/auth_checks", as: :json
        expect(response).to have_http_status(:ok)
        user_id = User.find_by!(email: user_params[:email]).id
        puts(user_id)
        expect(response.parsed_body["user_id"]).to eq(user_id)


      end
    end
    
    context "メールアドレスが登録済みの場合" do
      let!(:existing_user) { FactoryBot.create(:user) }

      let(:user_params) do
        FactoryBot.attributes_for(:user).merge(
          email: existing_user.email,
          prefecture_id: existing_user.prefecture_id
        )
      end

      it "ユーザーを登録できない" do
        expect {
          post "/users", params: { user: user_params }, as: :json
        }.not_to change(User, :count)

        expect(response.status).to eq(422)
      end
    end

    context "名前が空の場合" do
      let(:user_params) do
        FactoryBot.attributes_for(:user).merge(
          name: "",
          prefecture_id: prefecture.id
        )
      end

      it "ユーザー登録できない" do
        expect {
          post "/users", params: {user: user_params}, as: :json
        }.not_to change(User, :count)

        expect(response.status).to eq(422)
      end
    end

    context "emailが空の場合" do
      let(:user_params) do
        FactoryBot.attributes_for(:user).merge(
          prefecture_id: prefecture.id,
          email: ""
        )
      end

      it "ユーザー登録できない" do
        expect {
          post "/users", params: {user: user_params}, as: :json
        }.not_to change(User, :count)

        expect(response.status).to eq(422)
      end
    end
  end
end
