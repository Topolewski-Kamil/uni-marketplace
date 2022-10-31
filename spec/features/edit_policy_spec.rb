require "rails_helper"

feature "Edit policy pages" do

  #backup policy files before running tests
  before(:all) do
    policies_dir = Dir['./app/assets/markdown/*.md']
    backup_dir = './spec/testing-assets/markdown'

    policies_dir.each do |filename|
      FileUtils.cp(filename, backup_dir)
    end
  end

  #put the files back after all the tests
  after(:all) do
    backup_dir = Dir['./spec/testing-assets/markdown/*.md']
    policies_dir = './app/assets/markdown'

    backup_dir.each do |filename|
      FileUtils.cp(filename, policies_dir)
    end
  end

  before(:each) do
    @user = FactoryBot.create(:moderator)
    login_as(@user)
  end
  
  specify "I can access site policy editor from moderator dashboard" do
    visit "/moderator"
    within("main") {click_link "Edit Site Policy"}
    expect(current_path).to eq "/policies/edit/site_policy"
    expect(page).to have_content "Editing site policy"
  end

  specify "I can access Covid guidance editor from moderator dashboard" do
    visit "/moderator"
    within("main") {click_link "Edit COVID Policy"}
    expect(current_path).to eq "/policies/edit/covid-19"
    expect(page).to have_content "Editing Covid-19 policy"
  end
  
  specify "I can edit the site policy in editor" do
    visit "/policies/edit/site_policy"
    fill_in 'markdown', with: 'testing change - site policy'
    click_button 'Submit'
    visit "/policies/site_policy"
    expect(page).to have_content "testing change - site policy"
  end

  specify "I can edit the covid-19 guidance in editor" do
    visit "/policies/edit/covid-19"
    fill_in 'markdown', with: 'testing change - covid-19'
    click_button 'Submit'

    visit "/policies/covid-19"
    expect(page).to have_content "testing change - covid-19"
  end
end