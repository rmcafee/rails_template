# Replace with your current rails template directory
templates_path  = "/Users/rmcafee/rails_template/templates"

on_git = false

# Setup Git
run "cp #{templates_path}/engine_init.rb init.rb" if yes?("Is this an engine template?")
if yes?("You want to go ahead and set this project up on git?")
  git :init
  
  run "cp #{templates_path}/gitignore.standard .gitignore"
  run "cp #{templates_path}/compass.config config/compass.config"
  run "cp #{templates_path}/compass.rb config/initializers/compass.rb"
  run "cp config/database.yml config/example_database.yml"

  git :add => "."
  git :commit => "-a -m 'Initial Commit'"
    
  on_git = true
end

# Config Gems
gem 'haml', :source => 'http://gems.github.com'
gem 'justinfrench-formtastic', :lib => 'formtastic', :source  => 'http://gems.github.com'
gem 'mislav-will_paginate', :version => '>= 2.2.3', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'unicode', :lib => 'unicode'
gem 'chriseppstein-compass', :lib => 'compass'
gem 'rspec', :lib => false, :version => '>= 1.2.0'
gem 'rspec-rails', :lib => false, :version => '>= 1.2.0'
gem 'cucumber'
gem 'webrat'
gem 'thoughtbot-shoulda', :lib => false, :source => "http://gems.github.com"
gem "thoughtbot-factory_girl", :lib => "factory_girl", :source => "http://gems.github.com"

# Install Plugins
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git'
plugin 'rails_indexes', :git => 'git://github.com/eladmeidar/rails_indexes.git'
plugin 'validation_reflection', :git => 'git://github.com/redinger/validation_reflection.git'
plugin 'engine-addons', :git => "git://github.com/rmcafee/engine-addons.git"

# Using JS
run "cp #{templates_path}/jquery/* public/javascripts/" if yes?("You want to use Jquery?")

# Logic Gems
if yes?("You wish to use authlogic?")
  gem 'binarylogic-authlogic', :lib => 'authlogic', :git => 'git://github.com/binarylogic/authlogic.git'
  gem 'josevalim-auth_helpers', :lib => 'auth_helpers', :git => 'http://github.com/josevalim/auth_helpers/tree/master'
  gem 'josevalim-inherited_resources', :lib => 'inherited_resources', :git => 'http://github.com/josevalim/inherited_resources/tree/master'
end

if yes?("You wish to use searchlogic?")
  gem 'binarylogic-searchlogic', :lib => 'searchlogic', :git => 'git://github.com/binarylogic/searchlogic.git'
end

# Replace 'false' strings with actual false boolean variables
run %{perl -pi -w -e "s/'false'/false/g;" config/environment.rb}

# Rake Tasks
rake("gems:install", :sudo => true)

# Generators
generate("rspec")
generate("cucumber")

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
end

class String
  def to_slug
    str = Unicode.normalize_KD(self).gsub(/[^\x00-\x7F]/n,'')
    str = str.gsub(/\W+/, '-').gsub(/^-+/,'').gsub(/-+$/,'').downcase
  end
end
RUBY_EVAL

# custom_errors.rb
#run "cp #{templates_path}/custom_errors.rb config/initializers/custom_errors.rb"

# Recommit if on git
if on_git
  git :add => "."
  git :commit => "-a -m 'Templated Addons Initialized'"
end