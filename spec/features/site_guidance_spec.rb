require "rails_helper"

feature "View Guidance Pages" do
  before do
    @user = FactoryBot.create(:user)
    login_as(@user)
  end

  specify "I can access the site policies from the homepage footer" do
    visit "/"
    within("footer") {click_link "Site Policies"}
    expect(current_path).to eq "/policies/site_policy"
    expect(page).to have_content "Please review the website policy before selling or buying any items."
  end

  specify "I can access the COVID 19 guidance from the homepage footer" do
    visit "/"
    within("footer") {click_link "COVID-19 Guidance"}
    expect(current_path).to eq "/policies/covid-19"
    expect(page).to have_content "COVID-19 guidance for buying and selling using UoS marketplace."
  end

  specify "I can access the COVID 19 guidance from the site policies" do
    visit "/policies/site_policy"
    within("main"){within(".alert"){ click_link "here"}}
    expect(current_path).to eq "/policies/covid-19"
  end
end
