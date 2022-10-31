class AddLocationToListings < ActiveRecord::Migration[6.0]
  def change
    add_column :listings, :location, :text
  end
end
