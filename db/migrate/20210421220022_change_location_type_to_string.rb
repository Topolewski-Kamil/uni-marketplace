class ChangeLocationTypeToString < ActiveRecord::Migration[6.0]
  def change
    change_column :listing_contents, :location, :string
  end
end
