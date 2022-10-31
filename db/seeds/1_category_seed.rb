require_relative "../seeds_helper.rb"

categories = read_YAML_seed("categories")

categories.each do |category|
  Category.where(name: category).first_or_create
end
