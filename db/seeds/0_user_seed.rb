require_relative "../seeds_helper.rb"

users = read_YAML_seed("users")

users.each do |username, user_info|
    User.find_or_initialize_by(username: username).update(user_info)
end