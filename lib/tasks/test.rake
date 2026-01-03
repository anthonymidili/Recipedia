# Custom test task to work around Rails 8.1.x test discovery issues
# This task uses the Rake::TestTask with programmatic file discovery

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList.new(Dir.glob("test/**/*_test.rb"))
  t.warning = false
  t.verbose = true
end

namespace :test do
  desc "Run model tests"
  Rake::TestTask.new(:models) do |t|
    t.libs << "test"
    t.test_files = FileList.new(Dir.glob("test/models/**/*_test.rb"))
    t.warning = false
  end

  desc "Run controller tests"
  Rake::TestTask.new(:controllers) do |t|
    t.libs << "test"
    t.test_files = FileList.new(Dir.glob("test/controllers/**/*_test.rb"))
    t.warning = false
  end

  desc "Run system tests"
  Rake::TestTask.new(:system) do |t|
    t.libs << "test"
    t.test_files = FileList.new(Dir.glob("test/system/**/*_test.rb"))
    t.warning = false
  end

  desc "Run job tests"
  Rake::TestTask.new(:jobs) do |t|
    t.libs << "test"
    t.test_files = FileList.new(Dir.glob("test/jobs/**/*_test.rb"))
    t.warning = false
  end

  desc "Run channel tests"
  Rake::TestTask.new(:channels) do |t|
    t.libs << "test"
    t.test_files = FileList.new(Dir.glob("test/channels/**/*_test.rb"))
    t.warning = false
  end

  desc "Run service tests"
  Rake::TestTask.new(:services) do |t|
    t.libs << "test"
    t.test_files = FileList.new(Dir.glob("test/services/**/*_test.rb"))
    t.warning = false
  end

  desc "Run mailer tests"
  Rake::TestTask.new(:mailers) do |t|
    t.libs << "test"
    t.test_files = FileList.new(Dir.glob("test/mailers/**/*_test.rb"))
    t.warning = false
  end
end
