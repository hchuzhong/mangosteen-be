class Api::V1::ValidationCodesController < ApplicationController
  def create
    return render status: :too_many_requests if ValidationCode.exists?(email: params[:email], kind: 'sign_in', created_at: 1.minute.ago..Time.now)
    validation_code = ValidationCode.new email: params[:email], kind: 'sign_in'
    if validation_code.save
      render status: :ok
    else
      render json: {errors: validation_code.errors}, status: :unprocessable_entity
    end
  end
end
