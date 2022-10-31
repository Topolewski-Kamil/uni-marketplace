class AddListingToConversations < ActiveRecord::Migration[6.0]
  def change
    add_reference :conversations, :listing, null: false, foreign_key: true
  end
end
