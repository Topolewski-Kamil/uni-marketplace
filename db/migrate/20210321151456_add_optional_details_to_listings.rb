class AddOptionalDetailsToListings < ActiveRecord::Migration[6.0]
  def change
    add_column :listings, :condition, :string
    add_column :listings, :payment_options, :string
    add_column :listings, :delivery_options, :string
  end
end
