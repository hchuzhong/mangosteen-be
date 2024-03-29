class Tag < ApplicationRecord
  paginates_per 25
  default_scope { where(deleted_at: nil).order(created_at: :desc) }
  enum kind: { expenses: 1, income: 2 }
  validates :kind, presence: true
  validates :name, presence: true
  validates :name, length: { maximum: 18 }
  validates :sign, presence: true
  belongs_to :user
end
