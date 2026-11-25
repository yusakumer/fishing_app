require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  describe "GET /api/v1/users/me" do
    context "未ログインの場合" do
      it "401を返す" do
        get "/api/v1/users/me", as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "ログイン済みの場合" do
      let(:user) { FactoryBot.create(:user) }

      it "本人のプロフィールを200で返す" do
        post "/api/v1/users/sign_in",
             params: { user: { email: user.email, password: user.password } },
             as: :json
        expect(response).to have_http_status(:ok)

        get "/api/v1/users/me", as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq(
          "user" => {
            "id" => user.id,
            "name" => user.name,
            "prefecture_id" => user.prefecture_id,
            "photo_url" => nil
          }
        )
      end
    end
  end

  describe "PATCH /api/v1/users/me" do
    context "未ログインの場合" do
      let!(:user) { FactoryBot.create(:user) }

      it "401を返し、ユーザー情報を更新しない" do
        expect {
          patch "/api/v1/users/me",
                params: { user: { name: "更新用の名前" } },
                as: :json
        }.not_to change { user.reload.attributes }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "ログイン済みの場合" do
      let(:user) { FactoryBot.create(:user) }

      before do
        post "/api/v1/users/sign_in",
             params: { user: { email: user.email, password: user.password } },
             as: :json
        expect(response).to have_http_status(:ok)
      end

      context "入力が不正な場合" do
        it "名前が空なら422を返し、ユーザー情報を更新しない" do
          expect {
            patch "/api/v1/users/me",
                  params: { user: { name: "" } },
                  as: :json
          }.not_to change { user.reload.attributes }

          expect(response).to have_http_status(:unprocessable_content)
          expect(response.parsed_body["errors"]).to be_present
        end

        it "都道府県が空なら422を返し、名前も含めて更新しない" do
          expect {
            patch "/api/v1/users/me",
                  params: { user: { name: "更新用の名前", prefecture_id: nil } },
                  as: :json
          }.not_to change { user.reload.attributes }

          expect(response).to have_http_status(:unprocessable_content)
          expect(response.parsed_body["errors"]).to be_present
        end
      end

      context "正しい入力の場合" do
        let(:another_prefecture) { FactoryBot.create(:prefecture) }

        # 更新用のダミーデータ
        let(:update_params) do
          {
            name: "更新用の名前",
            prefecture_id: another_prefecture.id
          }
        end

        it "更新されたUser情報と200を返す" do
          patch "/api/v1/users/me",
                params: { user: update_params },
                as: :json
          expect(response).to have_http_status(:ok)

          # DBから読み直し、名前と都道府県が保存されたことを確認する
          user.reload
          expect(user.name).to eq(update_params[:name])
          expect(user.prefecture_id).to eq(another_prefecture.id)

          expect(response.parsed_body["user"]).to eq(
            "id" => user.id,
            "name" => update_params[:name],
            "prefecture_id" => another_prefecture.id,
            "photo_url" => nil
          )
        end
      end

      context "写真を送信する場合" do
        it "写真を保存し、photo_urlと200を返す" do
          # テスト用画像を、アップロードするファイルとして読み込む
          photo = fixture_file_upload(Rails.root.join("spec/fixtures/files/profile.png"), "image/png")

          # 画像はJSONではなくmultipart形式で送る
          patch "/api/v1/users/me",
                params: { user: { photo: photo } },
                headers: { "Accept" => "application/json" }

          expect(response).to have_http_status(:ok)

          # DBから読み直して、本人に送信した画像が紐づいたことを確認する
          user.reload
          expect(user.photo).to be_attached
          expect(user.photo.filename.to_s).to eq("profile.png")
          expect(user.photo.blob.content_type).to eq("image/png")
          expect(user.photo.download).to eq(File.binread(Rails.root.join("spec/fixtures/files/profile.png")))
          expect(response.parsed_body["user"]["photo_url"]).to be_present
        end
      end

      context "登録済みの写真を変更する場合" do
        it "新しい写真に差し替え、photo_urlと200を返す" do
          before_photo = fixture_file_upload(Rails.root.join("spec/fixtures/files/profile.png"), "image/png")
          

          patch "/api/v1/users/me",
                params: { user: { photo: before_photo } },
                headers: { "Accept" => "application/json" }

          expect(response).to have_http_status(:ok)
          
          user.reload
          before_blob_id = user.photo.blob.id
         
          
          after_photo = fixture_file_upload(Rails.root.join("spec/fixtures/files/profile_updated.png"), "image/png")
          
          patch "/api/v1/users/me",
                params: { user: { photo: after_photo } },
                headers: { "Accept" => "application/json" }

          
          
          expect(response).to have_http_status(:ok)
          
          user.reload
          
          expect(user.photo).to be_attached
          expect(user.photo.filename.to_s).to eq("profile_updated.png")
          expect(user.photo.blob.content_type).to eq("image/png")
          expect(user.photo.download).to eq(File.binread(Rails.root.join("spec/fixtures/files/profile_updated.png")))
          expect(response.parsed_body["user"]["photo_url"]).to be_present
          expect(user.photo.blob.id).not_to eq(before_blob_id)
          
          
          
          
        

        end
      end
    end
  end
end
