class AddApprovedToListing < ActiveRecord::Migration[6.0]
  def change
    add_column :listings, :approved, :boolean
    change_column_default :listings, :approved, false
  end
end
