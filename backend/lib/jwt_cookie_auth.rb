# frozen_string_literal: true
class JwtCookieAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    token = request.cookies["access_token"]
    if token.present? && env["HTTP_AUTHORIZATION"].nil?
      env["HTTP_AUTHORIZATION"] = "Bearer #{token}"
    end
    @app.call(env)
  end
end
