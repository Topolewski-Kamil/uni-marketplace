require "rails_helper"


feature "Moderator Dashboard" do
    
    before(:each) do
        @user = FactoryBot.create(:moderator)
        login_as(@user)
    end

    specify "I can access the moderator dashboard as a moderator" do
        visit "/"
        click_link "Moderator Dashboard"
        expect(page).to have_content "Utilities"
        expect(page).to have_content "Statistics"
    end

    specify "I cannot access the moderator dashboard as a regular user" do
        logout()
        @regular_user = FactoryBot.create(:user)
        login_as(@regular_user)

        visit "/moderator"
        expect(page).to have_content "You are not authorized"
    end
end