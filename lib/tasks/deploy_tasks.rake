namespace :deploy do
  task :demo_auto => [:demo, :seed_demo]

  task :demo do
    if is_branch_master
      puts "Deploying to demo server using epi_deploy"
      system("bundle exec epi_deploy release -d demo")
    else
      puts "Please switch to master branch first."
    end
  end

  task :seed_demo do
    if is_branch_master
      puts "Seeding demo server using epi_deploy"
      system("bundle exec cap demo deploy:seed")
    else
      puts "Please switch to master branch first."
    end
  end

  def is_branch_master
    current_git_branch = `git rev-parse --abbrev-ref HEAD`
    return current_git_branch == "master\n"
  end
end
