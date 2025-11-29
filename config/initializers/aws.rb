require "aws-sdk-s3"

if Rails.env.local?
  Aws.config.update(ssl_verify_peer: false)
end
