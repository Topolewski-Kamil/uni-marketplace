# == Schema Information
#
# Table name: conversations
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  buyer_id   :bigint
#  listing_id :bigint           not null
#  seller_id  :bigint
#
# Indexes
#
#  index_conversations_on_buyer_id    (buyer_id)
#  index_conversations_on_listing_id  (listing_id)
#  index_conversations_on_seller_id   (seller_id)
#
# Foreign Keys
#
#  fk_rails_...  (listing_id => listings.id)
#
require 'rails_helper'

RSpec.describe Conversation, type: :model do
  # describe "Conversations" do
  #   it {should belongs_to(:user)}
  # end
end
