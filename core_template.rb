template_base_path    = '/Users/rmcafee/rails_template'
core_template_path    = '/Users/rmcafee/rails_template/core_template.rb'

on_git = false

# Setup Git
run "cp #{template_base_path}/templates/engine_init.rb init.rb" if yes?("Is this an engine template?")
if yes?("You want to go ahead and set this project up on git?")
  git :init
  
  run "cp #{template_base_path}/templates/gitignore.standard .gitignore"
  run "cp config/database.yml config/example_database.yml"

  git :add => "."
  git :commit => "-a -m 'Initial Commit'"
    
  on_git = true
end

# Config Gems
gem 'haml', :source => 'http://gems.github.com'
gem 'justinfrench-formtastic', :lib => 'formtastic', :source  => 'http://gems.github.com'
gem 'rspec', :lib => false, :version => '>= 1.2.0'
gem 'rspec-rails', :lib => false, :version => '>= 1.2.0'
gem 'cucumber'
gem 'webrat'
gem 'thoughtbot-shoulda', :lib => 'shoulda', :source => "http://gems.github.com"
gem "thoughtbot-factory_girl", :lib => "factory_girl", :source => "http://gems.github.com"
gem 'mislav-will_paginate', :version => '>= 2.2.3', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'unicode', :lib => 'unicode'

# Install Plugins
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git'
plugin 'active_record_base_without_table', :git => 'git://github.com/notahat/active_record_base_without_table.git'
plugin 'validation_reflection', :git => 'git://github.com/redinger/validation_reflection.git'
plugin 'engine-addons', :git => "git://github.com/rmcafee/engine-addons.git"

# Using JS
run "cp ~/template_rails/templates/jquery/* public/javascripts/" if yes?("You want to use Jquery?")

# Logic Gems
if yes?("You wish to use authlogic?")
  gem 'binarylogic-authlogic', :lib => 'authlogic', :git => 'git://github.com/binarylogic/authlogic.git'
  gem 'josevalim-auth_helpers', :lib => 'auth_helpers', :git => 'http://github.com/josevalim/auth_helpers/tree/master'
  gem 'josevalim-inherited_resources', :lib => 'inherited_resources', :git => 'http://github.com/josevalim/inherited_resources/tree/master'
end
gem 'binarylogic-searchlogic', :lib => 'searchlogic', :git => 'git://github.com/binarylogic/searchlogic.git' if yes?("You wish to use searchlogic?")

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

# navigation_helper.rb
initializer 'navigation_control.rb', <<-RUBY_EVAL
class ActionController::Base
  # Set the current nav instance variable, used to set the current nav tab
  def self.set_current_nav(array_of_selected_items, options = {})
    set_instance_var_to_value("@current_nav", array_of_selected_items, options)
  end

  # :nodoc:
  def self.set_instance_var_to_value(instance_var, value, options = {})
    before_filter options do |instance |
      instance.instance_variable_set instance_var, value
    end
  end
  set_current_nav [:none]  
end
RUBY_EVAL

run "cp #{template_base_path}/templates/navigation_helper.rb app/helpers/navigation_helper.rb"

# custom_errors.rb
run "cp #{template_base_path}/templates/custom_errors.rb config/initializers/custom_errors.rb"

# Recommit if on git
if on_git
  git :add => "."
  git :commit => "-a -m 'Templated Addons Initialized'"
end