# -------------------------------------------
#  File additions
# -------------------------------------------

# README.md > README.rdoc
remove_file "README.rdoc"
file "README.md" do
  <<-README
# #{app_const_base}

Hello new project

README
end

# Add to .gitignore
run %q[echo "
/coverage/*
/.rvmrc
/.ruby-version
/.rbenv-gemsets
/.powrc

.DS_Store
.sass-cache
/public/system
" >> .gitignore]

# Add Guardfile
file "Guardfile" do
  <<-'EOF'
guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html|scss)})
  watch(%r{(app|vendor)(/assets/\w+/.+)\.s(c|a)ss}) { |m| "#{m[2]}.css" }
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|js|html|png|jpg))).*}) { |m| "/assets/#{m[3]}" }
end

guard 'rails' do
  watch('Gemfile.lock')
  watch(%r{^(config|lib)/.*})
end


EOF
end

# -------------------------------------------
#  Configure application
# -------------------------------------------

application do
%q[
    config.time_zone = 'Eastern Time (US & Canada)'

    config.generators do |g|
      g.assets false
      g.helper false
    end
]
end

# -------------------------------------------
#  Gemfile
# -------------------------------------------

# Use slim for templates
gem 'slim'
gem 'slim-rails'
gem 'redcarpet'
gem 'normalize-rails'
gem 'simple_form'
gem 'bcrypt', '~> 3.1.7'
gem 'foreigner'

# Better Errors for better stack traces, REPL, etc
gem_group :development do
  gem 'better_errors'
  gem 'quiet_assets'
  gem 'binding_of_caller'
  gem 'html2slim'

  # Live reload changes in browser
  gem 'rb-fsevent', :group => :osx
  gem 'guard'
  gem 'guard-livereload'
  gem 'guard-rails'
end

gem_group :test, :development do
  gem 'pry'
  gem 'rspec-rails', '~> 2.14.2'
  gem 'factory_girl_rails'
end

gem_group :test do
  gem 'capybara'
  gem 'shoulda-matchers'
  gem 'launchy', :require => false
end

gem_group :assets do
  gem 'compass-rails'
end

# Get Gemfile.lock a-ok for Heroku
run 'bundle install --without production'
run 'bundle update'


# -------------------------------------------
#  Slim > ERB
# -------------------------------------------

run 'erb2slim .'
remove_file "app/views/layouts/application.html.erb"

# -------------------------------------------
#  rspec > minitest
# -------------------------------------------

# Remove minitest and generate rspec
run "rm -fR test"
run "rails g rspec:install"
run "rm .rspec"

# Use custom .rspec as default has awful warnings enabled
file ".rspec" do
  <<-EOF
--color
--require spec_helper

EOF
end

run 'bundle exec spring binstub --all'

# -------------------------------------------
#  Init repo
# -------------------------------------------

git :init
git :add => "."
git :commit => "-a -m 'Initialize repo'"
