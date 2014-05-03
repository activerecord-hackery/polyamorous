source 'https://rubygems.org'
gemspec

gem 'rake'

rails = ENV['RAILS'] || '4-1-stable'

case rails
when /\// # A path
  gem 'activerecord', :path => "#{rails}/activerecord"
when /^v/ # A tagged version
  git 'git://github.com/rails/rails.git', :tag => rails do
    gem 'activerecord'
  end
else
  git 'git://github.com/rails/rails.git', :branch => rails do
    gem 'activerecord'
  end
end
