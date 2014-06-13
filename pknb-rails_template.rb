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
/config/database.yml
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
#  Gemfile
# -------------------------------------------

# Nevermind, just run a postgres db locally
# (use `-d` (`--database=`) flag with `rails new`)
# But it was such a nice --command-- hack though.

# # Initally remove sqlite3 (added into development)
# run %q[sed -n '/sqlite3/!p' ./Gemfile >> temp]
# remove_file 'Gemfile'
# run %q[mv temp Gemfile]

# Use slim for templates
gem 'slim'
gem 'slim-rails'
gem 'redcarpet'
gem 'normalize-rails'

# Better Errors for better stack traces, REPL, etc
gem_group :development do
  # gem 'sqlite3'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'html2slim'

  # Live reload changes in browser
  gem 'rb-fsevent', :group => :osx
  gem 'guard'
  gem 'guard-livereload'
  gem 'guard-rails'
end

# Get Gemfile.lock a-ok for Heroku
run 'bundle install --without production'
run 'bundle update'
run 'bundle install'

# -------------------------------------------
#  Slim > ERB
# -------------------------------------------

run 'erb2slim .'
remove_file "app/views/layouts/application.html.erb"

# -------------------------------------------
#  Init repo
# -------------------------------------------

git :init
git :add => "."
git :commit => "-a -m 'Initialize repo'"
