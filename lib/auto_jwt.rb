class AutoJwt
    def initialize(app)
        @app = app
    end
    def call(env)
        # skip if the path in the array
        return @app.call(env) if ['/api/v1/session'].include? env['PATH_INFO']
        header = env['HTTP_AUTHORIZATION']
        jwt = header.split(' ')[1] rescue ''
        begin
            payload = JWT.decode jwt, Rails.application.credentials.hmac_secret, true, { algorithm: 'HS256' }
        rescue JWT::ExpiredSignature
            return [401, {}, [JSON.generate({reason: 'Token expired'})]]
        rescue
            return [401, {}, [JSON.generate({reason: 'Invalid token'})]]
        end
        env['current_user_id'] = payload[0]['user_id'] rescue nil
        @status, @headers, @body = @app.call(env)
        [@status, @headers, @body]
    end
end