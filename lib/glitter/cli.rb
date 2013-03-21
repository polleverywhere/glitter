require 'thor'

module Glitter
  # Command line interface for cutting glitter builds
  class CLI < Thor
    desc "push", "pushes a build to a channel with release notes."
    method_option :notes, :type => :string, :aliases => "-m"
    method_option :version, :type => :string, :aliases => "-v"
    method_option :channel, :type => :string, :aliases => "-c"
    method_option :url, :type => :string, :aliases => "-u"
    #    "https://secret_access_key:access_key_id@aws.blah.com/bucket-name"

    def push(asset_path)
      Server.new(options.url).channel(options.channel).release do |release|
        release.notes   options.notes
        release.version options.version
        release.asset   File.open(asset_path)
      end.push.head
    end

    # desc "yank", "remove a build from a release channel"
    # method_option :version, :type => :string, :aliases => "-v"
    # method_option :channel, :type => :string, :aliases => "-c"
    # def yank
    # end

  end
end