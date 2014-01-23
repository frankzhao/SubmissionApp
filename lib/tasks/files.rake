namespace :files do
  desc "TODO"
  task :clear => :environment do
    system("rm -rf upload/*/*")
  end

end
