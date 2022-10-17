require 'sidekiq-scheduler'
require "rake"
Rails.application.load_tasks

class MidnightCron
  include Sidekiq::Worker

  def perform
    Rake::Task["clean_notifications"].reenable
    Rake::Task["clean_notifications"].execute

    if Rails.env.production?
      Rake::Task["sitemap:refresh"].reenable
      Rake::Task["sitemap:refresh"].execute
    else
      puts "Only refresh sitemap in production environment!!!"
    end
  end
end
