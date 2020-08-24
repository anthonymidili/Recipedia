web: bundle exec passenger start -p $PORT --max-pool-size $RAILS_MAX_THREADS
worker: bundle exec sidekiq -c 1 -t 25 -q default -q mailers -q low_priority
