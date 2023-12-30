class Item < ApplicationRecord
    paginates_per 25
    enum kind: { expenses: 1, income: 2 }
    validates :amount, presence: true
    validates :kind, presence: true
    validates :tag_ids, presence: true
    validates :happened_at, presence: true
    belongs_to :user

    validate :check_tag_id_belong_to_user

    def check_tag_id_belong_to_user
        all_tag_ids = Tag.where(user_id: self.user_id).map(&:id)
        if self.tag_ids & all_tag_ids != self.tag_ids
            self.errors.add :tag_ids, "is not belong to current user"
        end
    end

    def tags
        Tag.where(id: self.tag_ids)
    end
end
