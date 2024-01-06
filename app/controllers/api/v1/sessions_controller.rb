require 'jwt'

class Api::V1::SessionsController < ApplicationController
    def create
        session = Session.new params.permit :email, :code
        if session.valid?
            user = User.find_or_create_by email: session.email
            if !Rails.env.test?
                validation_code = ValidationCode.find_by(code: session.code, email: session.email)
                validation_code.used_at = Time.now
                validation_code.save
            end
            render status: :ok, json: { jwt: user.generate_jwt }
        else
            render status: :unprocessable_entity, json: { errors: session.errors }
        end
    end
end
