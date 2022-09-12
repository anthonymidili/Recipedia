# /Passengerfile.json points to mounting route for action cable.
web: bundle exec passenger start --max-pool-size $RAILS_MAX_THREADS --min-instances $RAILS_MAX_THREADS
worker: bundle exec sidekiq # -C config/sidekiq.yml
