require 's3'
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

  # The App class that a release uses to deploy
  class App
    TemplatePath = File.expand_path('../glitter/templates/Glitterfile', __FILE__).to_s.freeze
    RssTemplate = File.expand_path('../glitter/templates/rss.xml.erb', __FILE__).to_s.freeze
    AppcastXml = 'appcast.xml'

    include Configurable
    attr_configurable :name, :version, :archive, :s3

    class S3
      include Configurable
      attr_configurable :bucket_name, :access_key, :secret_access_key

      def url_for(path)
        "https://s3.amazonaws.com/#{bucket_name}/#{path}"
      end

      def service
        @service ||= ::S3::Service.new(:access_key_id => access_key, :secret_access_key => secret_access_key)
      end

      def bucket
        service.buckets.find(bucket_name)
      end
    end

    def s3(&block)
      @s3 ||= S3.configure(&block)
    end

    class Appcast
      ObjectName = 'appcast.xml'
      
      attr_reader :app

      def initialize(app)
        @app = app
      end

      def url
        app.s3.url_for ObjectName
      end

      def push
        object.content = rss
        object.save
      end

      def rss
        @rss ||= ERB.new(File.read(RssTemplate)).result(binding)
      end

    private
      def object
        @object ||= app.s3.bucket.objects.build(ObjectName)
      end
    end

    def appcast
      @appcast ||= Appcast.new(self)
    end

    def head
      releases[version]
    end

    def releases
      @releases ||= Hash.new do |hash,key|
        hash[key] = Release.new do |r|
          r.version = key
          r.app = self
        end
      end
    end
  end

  class Release
    attr_accessor :app, :version, :notes, :published_at
    attr_reader :object

    def initialize
      @published_at = Time.now
      yield self if block_given?
    end

    def name
      "#{app.name} #{version}"
    end

    def object_name
      "#{name.gsub(/\s/,'-').downcase}#{File.extname(file.path)}"
    end

    def object
      @object ||= app.s3.bucket.objects.build(object_name)
    end

    def url
      app.s3.url_for object_name
    end

    def push
      object.content = file
      object.save
    end

    def file
      File.new(app.archive)
    end
  end

  # Command line interface for cutting glitter builds
  class CLI < Thor
    desc "init PATH", "Generate a Glitterfile for the path"
    def init(path)
      glitterfile_path = File.join(path, 'Glitterfile')
      puts "Writing new Glitterfile to #{File.expand_path glitterfile_path}"

      File.open glitterfile_path, 'w+' do |file|
        file.write File.read(App::TemplatePath)
      end
    end

    desc "push RELEASE_NOTES", "pushes a build to S3 with release notes."
    def push(release_notes)
      puts "Pushing #{app.head.object_name} to bucket #{app.s3.bucket_name}..."
      app.head.push
      app.appcast.push
      puts "App pushed to #{app.head.url}"
    end

  private
    def app
      @config ||= App.configure('./Glitterfile')
    end
  end
end