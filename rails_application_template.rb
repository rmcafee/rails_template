gem_file = <<-GEMFILE_FILE
source 'https://rubygems.org'

gem 'rails', '4.0.0.beta1'

gem 'sqlite3' unless RUBY_PLATFORM =~ /java/i

gem 'jquery-rails'
gem 'turbolinks'

gem 'haml', '~> 4.0.0'

gem 'simple_form'
gem 'nested_form'
gem 'browser_details'

# File Uploads and Image Manipulation
gem 'carrierwave'
gem 'mini_magick'

# Security

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
gem 'jbuilder', '~> 1.0.1'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

group :assets do
  gem 'sass-rails',   '~> 4.0.0.beta1'
  gem 'coffee-rails', '~> 4.0.0.beta1'

  gem 'bootstrap-sass'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier',     '>= 1.0.3'
end

group :development, :test do
  gem 'rb-fsevent', '~> 0.9.1', :require => false if RUBY_PLATFORM =~ /darwin/i

  gem 'pry-rails'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-bundler'

  gem 'debugger'          unless RUBY_PLATFORM =~ /java/i
  
  gem 'better_errors'
  gem 'binding_of_caller' unless RUBY_PLATFORM =~ /java/i
  gem 'meta_request'
end

group :test do
  gem 'rspec-rails', '>= 2.10.1'
  gem 'capybara',    '~> 2.0.2'
  gem 'launchy'
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
.idea
.project
.bundle
db/*.sqlite3
db/*.db
db/schema.rb
log/*.log
tmp/
.sass-cache/
config/database.yml
.powder
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

# Edit Initializer
# gsub_file 'config/initializers/session_store.rb', /cookie_store.*/, "encrypted_cookie_store, :key => '#{`rake secret`.gsub(/\n/,"")}'"

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
copy_file("#{current_dir}/rails_application_template/assets/stylesheets/style.css.scss", "app/assets/stylesheets/style.css.scss")

# Spec Files
copy_file("#{current_dir}/rails_application_template/spec/spec_helper.rb", "spec/spec_helper.rb")
run("mkdir -p spec/integration")
run("mkdir -p spec/factories")

# Replace Layout
remove_file("app/views/layouts/application.html.erb")
copy_file("#{current_dir}/rails_application_template/views/layouts/application.html.haml", "app/views/layouts/application.html.haml")

# Prototype Support
if yes?("Do you want to set this application up to support instant prototyping?")
copy_file("#{current_dir}/rails_application_template/controllers/prototype_controller.rb", "app/controllers/prototype_controller.rb")
run("mkdir -p app/views/prototype")
copy_file("#{current_dir}/rails_application_template/views/prototype/index.html.haml", "app/views/prototype/index.html.haml")

gsub_file "config/routes.rb", 
          "# The priority is based upon order of creation: first created -> highest priority.", 
          "match '*path', controller: 'prototype', action: 'display_page', via: :all\n\t# The priority is based upon order of creation: first created -> highest priority."
end

# Finish Up
say <<-eos
============================================================================
Your new Rails application is ready to go.

Don't forget to scroll up for important messages from installed generators.
============================================================================
eos
