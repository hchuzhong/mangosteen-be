class Api::V1::TagsController < ApplicationController
    def index
        current_user = User.find request.env['current_user_id']
        return render status: :unauthorized if current_user.nil?
        tags = Tag.where(user_id: current_user).page(params[:page])
        tags = tags.where(kind: params[:kind]) if params[:kind]
        render json: { resources: tags, pager: {
            page: params[:page] || 1,
            per_page: Tag.default_per_page,
            count: Tag.count
        }}
    end
    def show
        current_user = User.find request.env['current_user_id']
        return render status: :unauthorized if current_user.nil?
        tag = Tag.find params[:id]
        return render status: :forbidden if tag.user_id != current_user.id
        if tag.errors.empty?
            render json: { resource: tag }, status: :ok
        else
            render json: { errors: tag.errors }, status: :unprocessable_entity
        end
    end
    def create
        current_user = User.find request.env['current_user_id']
        return render status: :unauthorized if current_user.nil?
        tag = Tag.new params.permit(:name, :sign, :kind)
        tag.user = current_user
        if tag.save
            render json: { resource: tag }, status: :ok
        else
            render json: { errors: tag.errors }, status: :unprocessable_entity
        end
    end
    def update
        current_user = User.find request.env['current_user_id']
        return render status: :unauthorized if current_user.nil?
        tag = Tag.find params[:id]
        return render status: :forbidden if tag.user_id != current_user.id
        tag.update params.permit(:name, :sign)
        if tag.errors.empty?
            render json: { resource: tag }, status: :ok
        else
            render json: { errors: tag.errors }, status: :unprocessable_entity
        end
    end
    def destroy
        current_user = User.find request.env['current_user_id']
        return render status: :unauthorized if current_user.nil?
        tag = Tag.find params[:id]
        return render status: :forbidden if tag.user_id != current_user.id
        tag.deleted_at = Time.now
        ActiveRecord::Base.transaction do
            begin
                tag.save!
                Item.where('tag_ids && ARRAY[?]::bigint[]', [tag.id]).update!(deleted_at: Time.now) if params[:with_items] == 'true'
            rescue
                return render json: { errors: tag.errors }, status: :unprocessable_entity
            end
            render json: { resource: tag }, status: :ok
        end
    end
end
