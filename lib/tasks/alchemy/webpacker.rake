namespace :alchemy do
  namespace :webpacker do
    desc "Install Alchemy JavaScript dependencies with yarn"
    task :yarn_install do
      Dir.chdir(File.join(__dir__, "../../..")) do
        system "yarn install --no-progress --production"
      end
    end

    desc "Compile Alchemy JavaScript packs using webpack for production with digests"
    task compile: [:yarn_install, :environment] do
      Webpacker.with_node_env("production") do
        MyEngine.webpacker.commands.compile || exit!
      end
    end
  end
end
