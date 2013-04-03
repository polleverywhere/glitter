require 'thor'

module Glitter
  # Command line interface for cutting glitter builds
  class CLI < Thor
    desc "push", "pushes a build to a channel with release notes."
    method_option :notes,   :type => :string, :aliases => "-n"
    method_option :version, :type => :string, :aliases => "-v"
    method_option :channel, :type => :string, :aliases => "-c"
    method_option :force, :type => :boolean, :aliases => "-f"
    def push(executable_path)
      p options
      server = Server.new.channel(options.channel)
      release = Release::Sparkle.new(server, options.version)
      release.notes       = options.notes
      release.executable  = File.open executable_path
      release.push(:force => options.force).head
    end

    desc "version", "print the version of glitter."
    def version
      puts Glitter::VERSION
    end

    # desc "yank", "remove a build from a release channel"
    # method_option :version, :type => :string, :aliases => "-v"
    # method_option :channel, :type => :string, :aliases => "-c"
    # def yank
    # end
  end
end