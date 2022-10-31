# == Schema Information
#
# Table name: listing_contents
#
#  id               :bigint           not null, primary key
#  approved         :boolean          default(FALSE)
#  condition        :string
#  delivery_options :string
#  description      :text
#  location         :string
#  payment_options  :string
#  post_code        :string
#  price            :float
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  category_id      :integer
#  listing_id       :integer
#
FactoryBot.define do

  factory :listing_content do
    title { "NewTitle" }
    description { "NewDescription" }
    price { 12.2 }
    location {"Sheffield"}
    delivery_options {"In person"}
  end
end
