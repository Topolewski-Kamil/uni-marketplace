# == Schema Information
#
# Table name: listings
#
#  id         :bigint           not null, primary key
#  archived   :boolean          default(FALSE)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_listings_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do

  factory :listing do
  end
end
