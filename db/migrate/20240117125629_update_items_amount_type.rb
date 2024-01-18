class UpdateItemsAmountType < ActiveRecord::Migration[7.0]
  def change
    change_column :items, :amount, :bigint
  end
end
