require 'thor'

module Glitter
  # Command line interface for cutting glitter builds
  class CLI < Thor
    desc "push", "Pushes a build to a channel with release notes."
    method_option :version,                 :type => :string, :aliases => "-v", :required => true
    method_option :channel,                 :type => :string, :aliases => "-c", :required => true
    method_option :notes,                   :type => :string, :aliases => "-n"
    method_option :bundle_version,          :type => :string, :aliases => "-b"
    method_option :minimum_system_version,  :type => :string, :aliases => "-m"
    method_option :force,                   :type => :boolean, :aliases => "-f"
    method_option :timeout,                 :type => :numeric, :aliases => "-t", :default => Server::DEFAULT_S3_TIMEOUT
    method_option :appcast_filename,        :type => :string, :aliases => "-a", :default => "appcast.xml"
    def push(executable_path, *asset_paths)
      release = Release::Sparkle.new(channel, options.version)
      release.minimum_system_version = options.minimum_system_version
      release.bundle_version = options.bundle_version
      release.notes       = options.notes
      release.executable  = File.open executable_path
      release.appcast_filename = options.appcast_filename if options.appcast_filename
      # For more complex releases, additional assets may need to go out with the build.
      asset_paths.each do |path|
        release.assets[File.basename(path)].tap do |asset|
          asset.content = File.open path
          asset.content_type = 'application/octet-stream'
        end
      end
      release.push(:force => options.force).head
    end

    desc "versions", "Prints pushed versions in a channel."
    method_option :channel, :type => :string, :aliases => "-c", :required => true
    def versions
      channel.versions.each do |version|
        puts version
      end
    end

    desc "channels", "Prints the channels on the server."
    def channels
      server.channel_versions.each do |channel, _|
        puts channel
      end
    end

    desc "version", "Prints the version of glitter."
    def version
      puts Glitter::VERSION
    end

  private
    def channel
      server.channel(options.channel)
    end

    def server
      @server ||= Server.new(timeout: options.timeout)
    end
  end
end
