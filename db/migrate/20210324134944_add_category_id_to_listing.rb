class AddCategoryIdToListing < ActiveRecord::Migration[6.0]
  def change
    add_column :listings, :category_id, :int
  end
end
