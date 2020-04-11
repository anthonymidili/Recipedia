web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 1 -t 25 -q default -q mailers -q low_priority
