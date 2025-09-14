# config/initializers/env.rb
if Rails.env.local? && File.exist?(".env")
  File.readlines(".env").each do |line|
    line.strip!
    if line.length > 0 && !line.start_with?("#")
      key, value = line.split("=", 2)
      ENV[key] = value
    end
  end
end
