class AddPostCodeToListingContents < ActiveRecord::Migration[6.0]
  def change
    add_column :listing_contents, :post_code, :string
  end
end
