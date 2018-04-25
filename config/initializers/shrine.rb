# require 'shrine'
# require 'shrine/storage/s3'
#
# Shrine.plugin :activerecord
# Shrine.plugin :logging, logger: Rails.logger
# Shrine.plugin :validation_helpers
#
# s3_options = {
#   access_key_id:      ENV['AWS_ACCESS_KEY_ID'],
#   secret_access_key:  ENV['AWS_SECRET_ACCESS_KEY'],
#   region:             ENV['AWS_REGION'],
#   bucket:             ENV['S3_BUCKET']
# }
#
# Shrine.storages = {
#   cache: Shrine::Storage::S3.new(prefix: "cache", **s3_options),
#   store: Shrine::Storage::S3.new(prefix: "store", **s3_options)
# }
