require "rails_helper"

RSpec.describe "Users controller", :type => :request do

  before(:each) do
    @user = FactoryBot.create(:moderator)
    login_as(@user)

    @user1 = User.create(username: 'search1test',
      givenname: 'searchTestName',
      sn: 'searchTestSurnameOne',
      email: 'emai1l@email.com',
      moderator: true)

    @user2 = User.create(username: 'search2test',
      givenname: 'searchTestName',
      sn: 'searchTestSurnameTwo',
      email: 'email2@email.com',
      moderator: false)

    @search_response_1 = {
      "id" => @user1.id,
      "username" => @user1.username,
      "fn" => @user1.givenname,
      "sn" => @user1.sn,
      "moderator" => @user1.moderator,
      "email" => @user1.email
    }.to_json

    @search_response_2 = {
      "id" => @user2.id,
      "username" => @user2.username,
      "fn" => @user2.givenname,
      "sn" => @user2.sn,
      "moderator" => @user2.moderator,
      "email" => @user2.email
    }.to_json

    @no_matches = {"success" => true, "matches" => nil}.to_json

    @both_matched = [@search_response_1, @search_response_2].to_json
  end

  describe "#get_moderators" do
    it "gives a list of moderators" do
      headers = { "ACCEPT" => "application/json" }
      get "/users/get_moderators/", :headers => headers
      expect(response).to have_http_status(200)
      expect(response.body).to include(@search_response_1)
    end

    it "denies access if not a moderator" do
      logout(@user)
      login_as(@user2)

      headers = { "ACCEPT" => "application/json" }
      get "/users/get_moderators/", :headers => headers
      expect(response).to have_http_status(403)
    end
  end

  describe "#search" do

    it "returns user hash when searching by username" do
      headers = { "ACCEPT" => "application/json" }
      get "/users/search/", :params => {:query => @user1.username}, :headers => headers

      expect(response).to have_http_status(200)
      expect(response.body).to match @search_response_1
    end

    it "returns user hash when searching by email" do
      headers = { "ACCEPT" => "application/json" }
      get "/users/search/", :params => {:query => @user1.email}, :headers => headers

      expect(response).to have_http_status(200)
      expect(response.body).to match @search_response_1
    end

    it "returns no matches when searching by email not in db" do
      headers = { "ACCEPT" => "application/json" }
      get "/users/search/", :params => {:query => "somenonexistingemail@email.com"}, :headers => headers

      expect(response).to have_http_status(200)
      expect(response.body).to match @no_matches
    end

    it "returns user hash when searching by full name" do
      headers = { "ACCEPT" => "application/json" }
      get "/users/search/", :params => {:query => "#{@user1.givenname} #{@user1.sn}"}, :headers => headers

      expect(response).to have_http_status(200)
      expect(response.body).to match @search_response_1
    end

    it "returns user hash when searching by first name" do
      headers = { "ACCEPT" => "application/json" }
      get "/users/search/", :params => {:query => @user1.givenname}, :headers => headers

      expect(response).to have_http_status(200)
      expect(response.body).to match @search_response_1
    end

    it "returns user hash when searching by surname" do
      headers = { "ACCEPT" => "application/json" }
      get "/users/search/", :params => {:query => @user1.sn}, :headers => headers

      expect(response).to have_http_status(200)
      expect(response.body).to match @search_response_1
    end

    it "returns two users with the same first name" do
      headers = { "ACCEPT" => "application/json" }
      get "/users/search/", :params => {:query => @user1.givenname}, :headers => headers

      expect(response).to have_http_status(200)
      expect(response.body).to match @both_matched
    end

    it "returns no matches when no matches" do
      headers = { "ACCEPT" => "application/json" }
      get "/users/search/", :params => {:query => "asiudfnbausif 123123 dsjfnbdjfbn"}, :headers => headers

      expect(response).to have_http_status(200)

      expect(response.body).to match @no_matches
    end

    it "returns no matches when no query" do
      headers = { "ACCEPT" => "application/json" }
      get "/users/search/", :params => {:query => ""}, :headers => headers

      expect(response).to have_http_status(200)
      expect(response.body).to match @no_matches

      get "/users/search/", :headers => headers
      expect(response).to have_http_status(200)
      expect(response.body).to match @no_matches
    end

    it "denies access if not a moderator" do
      logout(@user)
      login_as(@user2)

      headers = { "ACCEPT" => "application/json" }
      get "/users/search/", :headers => headers
      expect(response).to have_http_status(403)
    end

  end


  describe "#grant_moderator" do
    
    it "grants moderator previlages to non-moderator" do
      headers = { "ACCEPT" => "application/json" }
      post "/users/grant_moderator/", :params => {:id => @user2.id}, :headers => headers
      expect(response).to have_http_status(200)
    end

    it "returns 400 if already a mod" do
      headers = { "ACCEPT" => "application/json" }
      post "/users/grant_moderator/", :params => {:id => @user1.id}, :headers => headers
      expect(response).to have_http_status(400)
    end

    it "returns 400 if no id given" do
      headers = { "ACCEPT" => "application/json" }
      post "/users/grant_moderator/", :headers => headers
      expect(response).to have_http_status(400)
    end

    it "returns 400 if user not found" do
      id = @user2.id
      @user2.destroy
      headers = { "ACCEPT" => "application/json" }
      post "/users/grant_moderator/", :params => {:id => id}, :headers => headers
      expect(response).to have_http_status(400)
    end

    it "denies access if not a moderator" do
      logout(@user)
      login_as(@user2)

      headers = { "ACCEPT" => "application/json" }
      post "/users/grant_moderator/", :headers => headers
      expect(response).to have_http_status(403)
    end
  end


  describe "#revoke_moderator" do
    
    it "revokes moderator previlages of a moderator" do
      headers = { "ACCEPT" => "application/json" }
      post "/users/revoke_moderator/", :params => {:id => @user1.id}, :headers => headers
      expect(response).to have_http_status(200)
    end

    it "returns 400 if not a mod" do
      headers = { "ACCEPT" => "application/json" }
      post "/users/revoke_moderator/", :params => {:id => @user2.id}, :headers => headers
      expect(response).to have_http_status(400)
    end

    it "returns 400 if no id given" do
      headers = { "ACCEPT" => "application/json" }
      post "/users/revoke_moderator/", :headers => headers
      expect(response).to have_http_status(400)
    end

    it "returns 400 if user not found" do
      id = @user2.id
      @user2.destroy
      headers = { "ACCEPT" => "application/json" }
      post "/users/revoke_moderator/", :params => {:id => id}, :headers => headers
      expect(response).to have_http_status(400)
    end

    it "denies access if not a moderator" do
      logout(@user)
      login_as(@user2)

      headers = { "ACCEPT" => "application/json" }
      post "/users/revoke_moderator/", :headers => headers
      expect(response).to have_http_status(403)
    end
  end
end