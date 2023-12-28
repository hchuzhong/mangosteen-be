class Item < ApplicationRecord
    enum kind: { expenses: 1, income: 2 }
    validates :amount, presence: true
    validates :kind, presence: true
    validates :tags_id, presence: true
    validates :happened_at, presence: true
    belongs_to :user

    validate :check_tag_id_belong_to_user

    def check_tag_id_belong_to_user
        all_tag_ids = Tag.where(user_id: self.user_id).map(&:id)
        if self.tags_id & all_tag_ids != self.tags_id
            self.errors.add :tags_id, "is not belong to current user"
        end
    end
end
