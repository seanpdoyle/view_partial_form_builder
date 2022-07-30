source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in view_partial_form_builder.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

rails_version = ENV.fetch("RAILS_VERSION", "7.0")

rails_constraint =
  if rails_version == "main"
    {github: "rails/rails"}
  else
    "~> #{rails_version}.0"
  end

gem "rails", rails_constraint
gem "activemodel", rails_constraint
gem "sprockets-rails"

group :test do
  gem "activerecord-nulldb-adapter"
  gem "minitest-around"
end
