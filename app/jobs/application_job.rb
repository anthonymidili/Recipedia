class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError do |job, error|
    Rails.logger.error("Skipping job because of ActiveJob::DeserializationError (#{error.message})")
  end
end
