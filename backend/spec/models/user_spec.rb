require 'rails_helper'
require 'stringio'

RSpec.describe User, type: :model do
  describe "写真の容量チェック" do
    let(:user) { FactoryBot.build(:user) }

    context "写真がない場合" do
      it "有効である" do
        expect(user).to be_valid
      end
    end

    context "写真がある場合" do
      before do
        user.photo.attach(
          io: StringIO.new(File.binread(Rails.root.join("spec/fixtures/files/profile.png"))),
          filename: "profile.png",
          content_type: "image/png"
        )
      end

      context "写真が20MBちょうどの場合" do
        it "有効である" do
          # 実ファイルの容量ではなく、容量取得メソッドの返り値を置き換える
          allow(user.photo.blob).to receive(:byte_size).and_return(20.megabytes)

          expect(user).to be_valid
        end
      end

      context "写真が20MBを1バイト超える場合" do
        it "無効となり、写真の容量エラーを追加する" do
          allow(user.photo.blob).to receive(:byte_size).and_return(20.megabytes + 1)

          expect(user).not_to be_valid
          expect(user.errors[:photo]).to include("は20MB以下にしてください")
        end
      end
    end
  end
end
