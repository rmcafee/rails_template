# Replace with your current rails template directory
templates_path  = "/Users/rmcafee/rails_template/templates"

run "cp #{templates_path}/compass.config config/compass.config"
run "cp #{templates_path}/compass.rb config/initializers/compass.rb"
run "cp #{templates_path}/preinitializer.rb config/initializers/preinitializer.rb"

on_git = false

# Setup Git
run "cp #{templates_path}/engine_init.rb init.rb" if yes?("Is this an engine template?")
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
# plugin 'kata_pages', :git => "git://github.com/rmcafee/kata_pages.git"

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
file 'GEMFILE', <<-RUBY_EVAL
gem 'rails', '2.3.4'
gem 'haml'
gem 'justinfrench-formtastic'
gem 'will_paginate',            '>= 2.2.3'
gem 'unicode'
gem 'chriseppstein-compass'

gem 'rspec',                    '>= 1.2.0', :only => 'testing'
gem 'rspec-rails',              '>= 1.2.0', :only => 'testing'
gem 'cucumber',                             :only => 'testing'
gem 'webrat',                               :only => 'testing'
gem 'thoughtbot-shoulda',                   :only => 'testing'
gem 'thoughtbot-factory_girl',              :only => 'testing'
gem 'pickle',                               :only => 'testing'

source 'http://gemcutter.org'
source 'http://gems.github.com'
RUBY_EVAL

run "gem bundle"

# Recommit if on git
if on_git
  git :add => "."
  git :commit => "-a -m 'Templated Addons Initialized'"
end