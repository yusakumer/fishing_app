# frozen_string_literal: true
class JwtCookieAuth
  # ミドルウェアの組み立て時に、次の処理を担当するオブジェクトを受け取って保持する。
  def initialize(app)
    @app = app
  end

  # リクエストごとに呼ばれ、Cookie内のJWTをdevise-jwtが読むAuthorizationヘッダーへ渡す。
  # Cookieが空なら設定せず、既存のAuthorizationヘッダーがあれば上書きしない。
  # 署名・期限などの検証は行わず、リクエスト情報envを次の処理へ渡して応答を返す。
  def call(env)
    request = Rack::Request.new(env)
    token = request.cookies["access_token"]
    if token.present? && env["HTTP_AUTHORIZATION"].nil?
      env["HTTP_AUTHORIZATION"] = "Bearer #{token}"
    end
    @app.call(env)
  end
end
