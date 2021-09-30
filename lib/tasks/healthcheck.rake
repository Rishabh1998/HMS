namespace :healthcheck do
  desc "TODO"
  require 'httparty'
  task status: :environment do
    response = HTTParty.get("https://downtownstays.tk/healthcheck")
    puts(response)
  end

end
