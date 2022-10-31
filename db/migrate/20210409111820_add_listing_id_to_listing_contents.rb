class AddListingIdToListingContents < ActiveRecord::Migration[6.0]
  def change
    add_column :listing_contents, :listing_id, :int
  end
end
