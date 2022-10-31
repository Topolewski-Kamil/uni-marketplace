class AddDeletedToListings < ActiveRecord::Migration[6.0]
  def change
    add_column :listings, :deleted, :boolean
    change_column_default :listings, :deleted, false
  end
end
