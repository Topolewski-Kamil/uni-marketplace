require "rails_helper"

user = FactoryBot.create(:user)
moderator_user = FactoryBot.create(:user, moderator: true)

describe "Authenticating Users" do
  specify "I cannot access the site without logging in" do
    visit "/"
    expect(page).to have_content "You need to sign in or sign up before continuing."
  end

  specify "I cannot access the site with random login details" do
    visit "/"
    fill_in "Username", with: "gwgsed"
    fill_in "Password", with: "redggfeaw"
    click_button "Log in"
    expect(page).to have_content "Invalid Username or password."
  end

  specify "I can view the homepage as a user." do
    login_as(user, scope: :user)
    visit "/"
    expect(page).to_not have_content "You need to sign in or sign up before continuing."
    expect(page).to_not have_content "Log in"
    expect(current_path).to eq '/'
  end

  specify "I can view the homepage as a moderator user." do
    login_as(moderator_user, scope: :user)
    visit "/"
    expect(page).to_not have_content "You need to sign in or sign up before continuing."
    expect(page).to_not have_content "Log in"
    expect(current_path).to eq '/'
  end
end
