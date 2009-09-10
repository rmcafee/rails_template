engine_dir = File.dirname(__FILE__)
["#{engine_dir}/public", 
  "#{engine_dir}/vendor", 
  "#{engine_dir}/script",
  "#{engine_dir}/config/boot.rb",
  "#{engine_dir}/config/environment.rb",
  "#{engine_dir}/config/example_database.yml",
  "#{engine_dir}/config/database.yml",
  "#{engine_dir}/config/environments",
  "#{engine_dir}/config/initializers",
  "#{engine_dir}/config/locales",
  "#{engine_dir}/app/controllers/application_controller.rb",
  "#{engine_dir}/app/helpers/application_helper.rb",
  "#{engine_dir}/app/helpers/navigation_helper.rb",
  "#{engine_dir}/log",
  "#{engine_dir}/tmp",
  "#{engine_dir}/db/*.sqlite3",
  "#{engine_dir}/db/*.db"
].each { |path| system "rm -rf #{path}" if File.exist?(path) }