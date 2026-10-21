require 'rails_helper'

RSpec.describe "Users::Registrations", type: :request do
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
