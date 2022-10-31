# Run all seed scripts.
seed_scripts = Dir.entries("db/seeds/").select{|file| file.ends_with? "_seed.rb"}
seed_scripts = seed_scripts.sort_by{ |name| [name[/\d+/].to_i, name] }
seed_scripts.each do |script|
  require File.expand_path "db/seeds/" + script
end