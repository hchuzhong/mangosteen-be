require 'jwt'

class Api::V1::SessionsController < ApplicationController
    def create
        session = Session.new params.permit :email, :code
        if session.valid?
            user = User.find_or_create_by email: session.email
            render status: :ok, json: { jwt: user.generate_jwt }
        else
            render status: :unprocessable_entity, json: { errors: session.errors }
        end
    end
end
