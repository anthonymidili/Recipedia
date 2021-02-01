web: bundle exec passenger start -p $PORT --max-pool-size $RAILS_MAX_THREADS
worker: bundle exec sidekiq -C config/sidekiq.yml
