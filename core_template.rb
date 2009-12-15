# Replace with your current rails template directory
templates_path  = "/Users/rmcafee/rails_template/templates"

run "cp #{templates_path}/compass.config config/compass.config"
run "cp #{templates_path}/compass.rb config/initializers/compass.rb"
run "cp #{templates_path}/preinitializer.rb config/initializers/preinitializer.rb"

on_git = false
on_refinery = false

if yes?("You want to go ahead and set this project up with refinery cms?")
  on_refinery = true
end

# Setup Git
# run "cp #{templates_path}/engine_init.rb init.rb" if yes?("Is this an engine template?")
if yes?("You want to go ahead and set this project up on git?")
  git :init
  
  run "cp #{templates_path}/gitignore.standard .gitignore"
  run "cp config/database.yml config/example_database.yml"

  git :add => "."
  git :commit => "-a -m 'Initial Commit'"
    
  on_git = true
end

# Install Plugins
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git'
plugin 'rails_indexes', :git => 'git://github.com/eladmeidar/rails_indexes.git'
plugin 'validation_reflection', :git => 'git://github.com/redinger/validation_reflection.git'
plugin 'engine-addons', :git => "git://github.com/rmcafee/engine-addons.git"
plugin 'rails_xss', :git => "git://github.com/NZKoz/rails_xss.git"

# Setup Gems
gem 'formtastic', :source => 'http://gemcutter.org'

# Using JS
run "cp #{templates_path}/jquery/* public/javascripts/" if yes?("You want to use Jquery?")

# Replace 'false' strings with actual false boolean variables
run %{perl -pi -w -e "s/'false'/false/g;" config/environment.rb}

# Rake Tasks
# rake("gems:install", :sudo => true)

# Run Setup Commands
run 'haml --rails .'

# Addons
lib 'extensions.rb', <<-RUBY_EVAL
require 'unicode'

class Hash
  def only(*whitelist)
    {}.tap do |h|
      (keys & whitelist).each { |k| h[k] = self[k] }
    end
  end
  
  def +(other_hash)
    self.merge(other_hash) { |k, old_value, new_value| old_value + new_value }
  end
end

class String
  def to_slug
    # str = Unicode.normalize_KD(self).gsub(/[^\x00-\x7F]/n,'')
    # str = str.gsub(/\W+/, '-').gsub(/^-+/,'').gsub(/-+$/,'').downcase
    self.gsub(/[\W]/u, ' ').strip.gsub(/\s+/u, '-').gsub(/-\z/u, '').downcase.to_s
  end
end
RUBY_EVAL

# Put the required gems in development and test environments
unless on_refinery
  run "cp #{templates_path}/GEMFILE_ORIG Gemfile"
else
  run "cp #{templates_path}/GEMFILE_REFINERY Gemfile"
  run "refinery tmp_refine"
  run "cp -R tmp_refine/* ."
  run "rm -rf tmp_refine"
  run "rm -rf CONTRIBUTORS"
  run "rm -rf LICENSE"
  puts "*"*50
  puts '* Make sure to put: require "#{RAILS_ROOT}/vendor/gems/environment" at the top of preinitializer.rb file'
  puts '* Also remember to do "rake db:setup" '
  puts "*"*50
end
run "gem bundle"
generate "formtastic"

# Recommit if on git
if on_git
  git :add => "."
  git :commit => "-a -m 'Templated Addons Initialized'"
end

puts "*"*50
puts "Dont' forget to add sessions secret_key and secret to environment.rb"
puts "config.action_controller.session = { :session_key => '_new_app_session', :secret => 'your secret'}"
puts "*"*50

puts "*"*50
puts "Silence the gem warnings you'll get in Rails"
puts "Rails::VendorGemSourceIndex.silence_spec_warnings = true"
puts "*"*50