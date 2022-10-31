class RenameListingToListingContents < ActiveRecord::Migration[6.0]
  def change
    rename_table :listings, :listing_contents
  end
end
