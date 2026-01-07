# frozen_string_literal: true

# Custom AWS SDK adapter for sitemap_generator that uses the non-deprecated AWS SDK methods
module SitemapAdapters
  class AwsSdkAdapter
    attr_accessor :bucket, :aws_access_key_id, :aws_secret_access_key, :aws_region, :aws_session_token

    def initialize(bucket, options = {})
      @bucket = bucket
      @aws_access_key_id = options[:aws_access_key_id]
      @aws_secret_access_key = options[:aws_secret_access_key]
      @aws_region = options[:aws_region]
      @aws_session_token = options[:aws_session_token]
    end

    # Call with a SitemapLocation and string data
    def write(location, raw_data)
      credentials = Aws::Credentials.new(
        aws_access_key_id,
        aws_secret_access_key,
        aws_session_token
      )

      s3 = Aws::S3::Resource.new(
        region: aws_region,
        credentials: credentials
      )

      obj = s3.bucket(bucket).object(location.path_in_public)

      # Use the non-deprecated put method instead of upload_file
      obj.put(
        body: raw_data,
        acl: "public-read",
        cache_control: "private, max-age=0, no-cache",
        content_type: "application/xml"
      )
    end
  end
end
