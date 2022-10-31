class RemoveUserFromListingContent < ActiveRecord::Migration[6.0]
  def change
    remove_reference :listing_contents, :user, null: false, foreign_key: true
  end
end
