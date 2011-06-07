require 'aws/s3'
require 'thor'
require 'erb'

module Glitter
  # This mix-in Creates a DSL for configuring a class.
  module Configurable
    def self.included(base)
      base.send :extend,  ClassMethods
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def configure(path=nil,&block)
        path ? instance_eval(File.read(path), path) : instance_eval(&block)
        self
      end
    end

    module ClassMethods
      def attr_configurable(*attrs)
        attrs.each do |attr|
          class_eval %(
            attr_writer :#{attr}
            attr_overloaded :#{attr})
        end
      end

      def attr_overloaded(*attrs)
        attrs.each do |attr|
          class_eval(%{
            def #{attr}(val=nil)
              val ? instance_variable_set('@#{attr}', val) : instance_variable_get('@#{attr}')
            end})
        end
      end

      def configure(*args, &block)
        new.configure(*args, &block)
      end
    end
  end

  # The configuration class that a release uses to deploy
  class Configuration
    TemplatePath = File.expand_path('../glitter/templates/Glitterfile', __FILE__).to_s.freeze

    include Configurable
    attr_configurable :name, :version, :archive, :release_notes, :s3

    class S3
      include Configurable
      attr_configurable :bucket, :access_key, :secret_access_key

      def credentials
        {:access_key_id => access_key, :secret_access_key => secret_access_key}
      end
    end

    def s3(&block)
      @s3 ||= S3.configure(&block)
    end
  end

  class Release
    FeedTemplate = File.expand_path('../glitter/templates/rss.xml', __FILE__).to_s.freeze

    attr_accessor :config, :released_at

    def push
      bucket.new_object(archive_name, file, bucket)
    end

    def initialize(config)
      @config, @released_at = config, Time.now
      AWS::S3::Base.establish_connection! config.s3.credentials
    end

    def name
      "#{config.name} #{config.version}"
    end

    def object_name
      "#{name.downcase.gsub(/\s/,'-')}#{File.extname(config.archive)}"
    end

    def pub_date
      released_at.strftime("%a, %d %b %Y %H:%M:%S %z")
    end

    def appcast_url
      url_for 'appcast.xml'
    end

    def url
      url_for object_name
    end

    def to_rss
      @rss ||= ERB.new(File.read(FeedTemplate)).result(binding)
    end

    def file
      @file ||= File.open(config.archive, 'r')
    end

    def push
      AWS::S3::S3Object.store(object_name, File.open(config.archive), config.s3.bucket)
      AWS::S3::S3Object.store('appcast.xml', to_rss, config.s3.bucket)
    end

    def yank
      AWS::S3::S3Object.store(object_name, config.s3.bucket)
    end

  private
    def url_for(path)
      "https://s3.amazonaws.com/#{config.s3.bucket}/#{path}"
    end
  end

  # Command line interface for cutting glitter builds
  class CLI < Thor
    desc "init PATH", "Generate a Glitterfile for the path"
    def init(path)
      glitterfile_path = File.join(path, 'Glitterfile')
      puts "Writing new Glitterfile to #{File.expand_path glitterfile_path}"

      File.open glitterfile_path, 'w+' do |file|
        file.write File.read(Configuration::TemplatePath)
      end      
    end

    desc "push", "pushes a build to S3"
    def push
      puts "Pushing #{release.object_name} to bucket #{config.s3.bucket}..."
      release.push
      puts "Pushed to #{release.url}!"
    end

  private
    def config
      @config ||= Configuration.configure('./Glitterfile')
    end

    def release
      @release ||= Release.new(config)
    end
  end
end