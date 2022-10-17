require 'sidekiq-scheduler'

class MidnightCron
  include Sidekiq::Worker

  def perform
    %x(bundle exec rake clean_notifications)

    if Rails.env.production?
      %x(bundle exec rake sitemap:refresh)
    else
      puts "Only refresh sitemap in production environment!!!"
    end
  end
end
