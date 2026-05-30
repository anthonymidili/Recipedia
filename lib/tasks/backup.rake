namespace :db do
  desc "Backup database to S3"
  task backup_to_s3: :environment do
    require "aws-sdk-s3"
    require "fileutils"

    db_config = ActiveRecord::Base.connection_db_config
    database = db_config.database
    username = db_config.username
    host = db_config.host
    port = db_config.port || 5432

    timestamp = Time.current.strftime("%Y-%m-%dT%H-%M-%S-%3NZ")
    backup_file = "/tmp/backup-#{timestamp}.sql.gz"

    begin
      puts "Starting PostgreSQL backup..."

      # Create backup using pg_dump
      cmd = "PGPASSWORD='#{db_config.password}' pg_dump -h #{host} -p #{port} -U #{username} #{database} | gzip > #{backup_file}"
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

      s3_key = "backups/backup-#{timestamp}.sql.gz"
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

