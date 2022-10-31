class AddArchivedToListings < ActiveRecord::Migration[6.0]
  def change
    add_column :listings, :archived, :boolean
    change_column_default :listings, :archived, false
  end
end
