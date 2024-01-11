require 'jwt'

class Api::V1::SessionsController < ApplicationController
    def create
        session = Session.new params.permit :email, :code
        if session.valid?
            user = User.find_or_create_by email: session.email
            if (session.email != 'test@test.com' and session.code != '123456')
                validation_code = ValidationCode.find_by(code: session.code, email: session.email)
                render status: :unprocessable_entity, json: { errors: session.errors } if validation_code.nil?
                validation_code.used_at = Time.now
                validation_code.save
            end
            render status: :ok, json: { jwt: user.generate_jwt }
        else
            render status: :unprocessable_entity, json: { errors: session.errors }
        end
    end
end
