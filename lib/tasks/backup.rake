namespace :db do
  desc "Backup database to S3"
  task backup_to_s3: :environment do
    require "aws-sdk-s3"
    require "fileutils"
    require "uri"

    # Railway exposes DATABASE_PRIVATE_URL for internal networking; fall back to
    # DATABASE_URL when running outside Railway (e.g. local testing).
    database_url = ENV["DATABASE_PRIVATE_URL"].presence || ENV["DATABASE_URL"].presence

    if database_url.blank?
      raise "No database URL found. Set DATABASE_PRIVATE_URL or DATABASE_URL."
    end

    uri      = URI.parse(database_url)
    host     = uri.host
    port     = uri.port || 5432
    username = uri.user
    password = uri.password
    database = uri.path.delete_prefix("/")

    timestamp = Time.current.strftime("%Y-%m-%dT%H-%M-%S-%3NZ")
    backup_file = "/tmp/backup-#{timestamp}.sql.gz"

    begin
      puts "Starting PostgreSQL backup..."

      # Create backup using pg_dump
      cmd = "PGPASSWORD='#{password}' pg_dump -h #{host} -p #{port} -U #{username} #{database} | gzip > #{backup_file}"
      system(cmd)

      unless File.exist?(backup_file)
        raise "Backup file not created"
      end

      puts "Backup created: #{backup_file}"

      # Upload to S3
      s3_client = Aws::S3::Client.new(
        access_key_id: ENV["AWS_ACCESS_KEY_ID"],
        secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
        region: ENV["AWS_S3_REGION"]
      )

      s3_key = "backup-#{timestamp}.sql.gz"
      file_content = File.read(backup_file)

      s3_client.put_object(
        bucket: ENV["AWS_S3_BUCKET"],
        key: s3_key,
        body: file_content
      )

      puts "Backup uploaded to s3://#{ENV['AWS_S3_BUCKET']}/#{s3_key}"

      # Cleanup
      FileUtils.rm(backup_file)
      puts "Backup complete!"
    rescue => e
      puts "Backup failed: #{e.message}"
      raise
    end
  end
end
