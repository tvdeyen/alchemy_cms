# config valid for current version and patch releases of Capistrano
lock "~> 3.10.1"

set :application, "alchemy-demo"
set :repo_url, "https://github.com/AlchemyCMS/alchemy_cms"

set :deploy_to, "/var/www/#{fetch(:application)}"
set :public_path, "#{fetch(:release_path)}/spec/dummy/public"

append :linked_files, "Rakefile", 'spec/dummy/config/database.yml', 'spec/dummy/config/secrets.yml'

set :ssh_options, {
  keys: %w(`$HOME/.ssh/id_rsa`),
  forward_agent: true
}

set :bundle_without, nil
set :bundle_flags, nil
