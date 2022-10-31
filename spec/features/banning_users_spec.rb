require "rails_helper"

feature "Banning users" do

  context "Banning and unbanning", js: true do

    specify "As a moderator I can ban users" do
      @mod = FactoryBot.create(:moderator)
      @user = FactoryBot.create(:user)
      login_as(@mod)
  
      visit "/users/#{@user.id}"
  
      expect(page).to have_content 'Ban User'

      # Click button and accept alert confirming ban
      accept_alert do
        click_button 'Ban User'
      end

      # Button changed to Lift Ban and user object changed
      expect(page).to have_content 'Lift Ban'
      @user.reload
      expect(@user.isBanned?).to be true
    end

    specify "As a moderator I can unban users" do
      @mod = FactoryBot.create(:moderator)
      @user = FactoryBot.create(:user, banned: true)
      login_as(@mod)
  
      visit "/users/#{@user.id}"
  
      expect(page).to have_content 'Lift Ban'

      # Click button and accept alert confirming ban
      accept_alert do
        click_button 'Lift Ban'
      end

      # Button changed to Lift Ban and user object changed
      expect(page).to have_content 'Ban User'
      @user.reload
      expect(@user.isBanned?).to be false
    end
  end

  context "Banned user cannot access pages after logging in" do
    
    specify "As a banned user I am told about the ban when I log in" do
      @user = FactoryBot.create(:user, banned: true)
      login_as(@user)
      visit "/"
      expect(current_path).to eq "/pages/banned"
      expect(page).to have_content "It looks like you were banned :("

      # also can log out
      click_link "Log out"
      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "Ability to ban" do
    
    specify "As a normal user I cannot see the ban button" do
      @user = FactoryBot.create(:user)
      @otherUser = FactoryBot.create(:user)
      login_as(@user)
      visit "/users/#{@otherUser.id}"
      expect(page).to have_content "givenname"
      expect(page).to_not have_content "Ban User"
      expect(page).to_not have_content "Lift Ban"

      visit "/users/#{@user.id}"
      expect(page).to have_content "givenname"
      expect(page).to_not have_content "Ban User"
      expect(page).to_not have_content "Lift Ban"
    end
  end

end