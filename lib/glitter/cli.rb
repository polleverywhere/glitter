require 'thor'

module Glitter
  # Command line interface for cutting glitter builds
  class CLI < Thor
    desc "push", "pushes a build to a channel with release notes."
    method_option :version, :type => :string, :aliases => "-v", :required => true
    method_option :channel, :type => :string, :aliases => "-c", :required => true
    method_option :notes,   :type => :string, :aliases => "-n"
    method_option :force,   :type => :boolean, :aliases => "-f"
    def push(executable_path)
      release = Release::Sparkle.new(channel, options.version)
      release.notes       = options.notes
      release.executable  = File.open executable_path
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

    # desc "yank", "remove a build from a release channel"
    # method_option :version, :type => :string, :aliases => "-v"
    # method_option :channel, :type => :string, :aliases => "-c"
    # def yank
    # end

  private
    def channel
      server.channel(options.channel)
    end

    def server
      @server ||= Server.new
    end
  end
end