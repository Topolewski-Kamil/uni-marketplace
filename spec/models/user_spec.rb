# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  banned             :boolean          default(FALSE)
#  current_sign_in_at :datetime
#  current_sign_in_ip :inet
#  dn                 :string
#  email              :string           default(""), not null
#  givenname          :string
#  last_sign_in_at    :datetime
#  last_sign_in_ip    :inet
#  mail               :string
#  moderator          :boolean
#  ou                 :string
#  sign_in_count      :integer          default(0), not null
#  sn                 :string
#  uid                :string
#  username           :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_email     (email)
#  index_users_on_username  (username)
#
require 'rails_helper'

RSpec.describe User, type: :model do

  describe "#show_moderators" do
    it "returns an array with all moderators' display information" do
      u = User.create(username: 'username', givenname: 'givenname', sn: 'sn', email: 'example@gmail.com', moderator: true)
      mods = User.show_moderators
      expect(mods.length).to eq(1)
      expect(mods[0]['username']).to match 'username'
      expect(mods[0]['moderator']).to be true
    end

    it "returns nil if there are none moderators" do
      mods = User.show_moderators
      expect(mods).to be nil
    end
  end


  describe "#get_display_information" do
    it "creates a hash with user id, username, name, email and moderator previlages" do
      u = User.create(username: 'username', givenname: 'givenname', sn: 'sn', email: 'example@gmail.com', moderator: false)
      h = u.get_display_information

      expect(h["username"]).to match 'username'
      expect(h["fn"]).to match 'givenname'
      expect(h["sn"]).to match 'sn'
      expect(h["email"]).to match 'example@gmail.com'
      expect(h["moderator"]).to be false
      expect(h["id"]).to_not be nil
    end

    it "sets email to 'None' if email field is empty" do
      u = User.create(username: 'email_user_username', givenname: 'givenname', sn: 'sn', moderator: false)
      h = u.get_display_information
      
      expect(h["email"]).to match 'None'
      expect(User.find_by(username: 'email_user_username').email.empty?).to be true
    end
  end


  describe '#grant_moderator!' do
    it "sets moderator field to true" do
      u = User.create(username: 'mod_test_username', givenname: 'mod_test_username_fn', moderator: false)
      u.grant_moderator!
      expect(User.find_by(username: 'mod_test_username', givenname: 'mod_test_username_fn').moderator).to be true
    end

    it "doesn't change moderator previlages if already has them" do
      u = User.create(username: 'mod_test_username', givenname: 'mod_test_username_fn', moderator: true)
      u.grant_moderator!
      expect(User.find_by(username: 'mod_test_username', givenname: 'mod_test_username_fn').moderator).to be true
    end
  end


  describe '#revoke_moderator!' do
    it "sets moderator field to false" do
      u = User.create(username: 'mod_test_username', givenname: 'mod_test_username_fn', moderator: true)
      u.revoke_moderator!
      expect(User.find_by(username: 'mod_test_username', givenname: 'mod_test_username_fn').moderator).to be false
    end

    it "doesn't change moderator previlages if already not a moderator" do
      u = User.create(username: 'mod_test_username', givenname: 'mod_test_username_fn', moderator: false)
      u.revoke_moderator!
      expect(User.find_by(username: 'mod_test_username', givenname: 'mod_test_username_fn').moderator).to be false
    end
  end


  describe '#isModerator?' do
    it "returns true if the user is a moderator" do
      u = User.create(username: 'mod_test_username', givenname: 'mod_test_username_fn', moderator: true)
      expect(u.isModerator?).to be true
    end

    it "returns false if the user is not a moderator" do
      u = User.create(username: 'mod_test_username', givenname: 'mod_test_username_fn', moderator: false)
      expect(u.isModerator?).to be false
    end
  end


  describe '#show_user' do
    before do
      @user = FactoryBot.create :user, givenname: "Test", sn: "User"
    end

    it "Returns the user's name in a readable format" do
      expect(@user.show_user).to eq 'Test U.'
    end
  end

  
  describe '#get_users_listings_info' do
    before do
      @user = FactoryBot.create :user, givenname: "Test", sn: "User"
      @listing1 = FactoryBot.create :listing, user: @user
      @listing2 = FactoryBot.create :listing, user: @user
      category = FactoryBot.create :category
      @content1 = FactoryBot.create :listing_content, category: category, listing: @listing1
      @content2 = FactoryBot.create :listing_content, category: category, listing: @listing2, approved: true
    end

    it "Returns all approved and non-approved listings created by the user, if the profile is theirs" do
      expect(@user.get_users_listings_info(true)).to eq [{listing: @listing2, content: @content2, pending: false},{listing: @listing1, content: @content1, pending: true}]
    end

    it "Returns only approved listings if the profile isn't theirs" do
      expect(@user.get_users_listings_info(false)).to eq [{listing: @listing2, content: @content2, pending: false}]
    end
  end


  describe '#ban!' do
    it "Sets banned field to true" do
      @user = FactoryBot.create :user, givenname: "Test", sn: "User"
      expect(@user.isBanned?).to eq false

      @user.ban!
      expect(@user.isBanned?).to eq true
    end

    it "Does nothing if user already banned" do
      @user = FactoryBot.create :user, givenname: "Test", sn: "User", banned: true
      expect(@user.isBanned?).to eq true

      @user.ban!
      expect(@user.isBanned?).to eq true
    end
  end

  describe '#unban!' do
    it "Sets banned field to false" do
      @user = FactoryBot.create :user, givenname: "Test", sn: "User", banned: true
      expect(@user.isBanned?).to eq true

      @user.unban!
      expect(@user.isBanned?).to eq false
    end

    it "Does nothing if user already unbanned" do
      @user = FactoryBot.create :user, givenname: "Test", sn: "User", banned: false
      expect(@user.isBanned?).to eq false

      @user.unban!
      expect(@user.isBanned?).to eq false
    end
  end

  describe '#isBanned?' do
    it "Returns true if user is banned" do
      @user = FactoryBot.create :user, givenname: "Test", sn: "User", banned: true
      expect(@user.isBanned?).to eq true
    end

    it "Returns false if user is not banned" do
      @user = FactoryBot.create :user, givenname: "Test", sn: "User", banned: false
      expect(@user.isBanned?).to eq false
    end
  end
end
