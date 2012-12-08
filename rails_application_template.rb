gem_file = <<-GEMFILE_FILE
source 'https://rubygems.org'

gem 'rails', '3.2.9'

ruby '1.9.3'

gem 'sqlite3'
gem 'jquery-rails'
gem 'haml-rails'
gem 'simple_form'
gem 'nested_form'
gem 'carrierwave'
gem 'mini_magick'
gem 'ransack'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'bootstrap-sass'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier',     '>= 1.0.3'
end

group :development, :test do
  gem "pry-rails"
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-bundler'

  gem 'debugger'  
end

group :test do
  gem 'rspec-rails', '>= 2.10.1'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'

  gem 'simplecov', :require => false
end
GEMFILE_FILE

# Set Ruby Version in Bundler Gem
create_file('Gemfile', gem_file)

# Default Generators
generators = <<-GENERATORS
  config.generators do |g|
    g.stylesheets false
    g.javascripts false
    # g.form_builder :simple_form # This is used automatically - no need to add it
    g.test_framework :rspec, :fixture => true, :views => false  
    g.fallbacks[:rspec] = :test_unit   
    g.fixture_replacement :factory_girl
    g.template_engine :haml
    g.integration_tool :rspec
    g.helper false
  end 
GENERATORS

application generators


# Update Files
gsub_file "config/application.rb", "config.filter_parameters += [:password]", "config.filter_parameters += [:password, :password_confirmation]"

# Clean Up Rails Defaults
remove_file "public/index.html"
remove_file "rm public/images/rails.png"
run "cp config/database.yml config/database.example.yml"
run "echo 'config/database.yml' >> .gitignore"

# Add some files for maintenance
ignore_file = <<-ignoreDATA
.DS_Store
.bundle
db/*.sqlite3
db/schema.rb
log/*.log
tmp/
.sass-cache/
config/database.yml
ignoreDATA

create_file ".gitignore", ignore_file

# Ban Spiders
gsub_file 'public/robots.txt', /# User-Agent/, 'User-Agent'
gsub_file 'public/robots.txt', /# Disallow/, 'Disallow'


# Adding Guard Support
guard_file = <<-guardDATA
guard 'bundler' do
  watch('Gemfile')
  # Uncomment next line if Gemfile contain 'gemspec' command
  # watch(/^.+\.gemspec/)
end

guard 'rspec', :cli => '--color --format nested --fail-fast' do
  watch('spec/spec_helper.rb')                       { "spec" }
  watch('config/routes.rb')                          { "spec/routing" }
  watch('app/controllers/application_controller.rb') { "spec/controllers" }
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^app/(.+)\.rb})                           { |m| "spec/\#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb})                           { |m| "spec/lib/\#{m[1]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb})  { |m| ["spec/routing/\#{m[1]}_routing_spec.rb", "spec/\#{m[2]}s/\#{m[1]}_\#{m[2]}_spec.rb", "spec/acceptance/\#{m[1]}_spec.rb"] }
end
guardDATA

create_file "Guardfile", guard_file

# Commit to Git
git :init
git :add => "."
git :commit => "-a -m 'Initial Commit'"

run 'bundle'

# Run Generators
generate('rspec:install')
generate('simple_form:install --bootstrap')
generate('nested_form:install')

# Copy Files
current_dir = File.dirname(__FILE__)

# Javascripts
copy_file("#{current_dir}/rails_application_template/assets/javascripts/application.js", "app/assets/javascripts/application.js")
copy_file("#{current_dir}/rails_application_template/assets/javascripts/bootstrap-datepicker.js", "app/assets/javascripts/bootstrap-datepicker.js")

# Styles
copy_file("#{current_dir}/rails_application_template/assets/stylesheets/application.css", "app/assets/stylesheets/application.css")
copy_file("#{current_dir}/rails_application_template/assets/stylesheets/datepicker.css", "app/assets/stylesheets/datepicker.css")
create_file("app/assets/stylesheets/style.scss")

# Spec Files
copy_file("#{current_dir}/rails_application_template/spec/spec_helper.rb", "spec/spec_helper.rb")
run("mkdir -p spec/integration")
run("mkdir -p spec/factories")

# Replace Layout
remove_file("app/views/layouts/application.html.erb")
copy_file("#{current_dir}/rails_application_template/views/layouts/application.html.haml", "app/views/layouts/application.html.haml")

# Finish Up
say <<-eos
============================================================================
Your new Rails application is ready to go.

Don't forget to scroll up for important messages from installed generators.
============================================================================
eos