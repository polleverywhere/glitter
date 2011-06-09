require 'spec_helper'
require 'rexml/document'

describe Glitter::App do
  before(:all) do
    @app = Glitter::App.configure do
      name          "My App"
      version       "1.0.0"
      archive       "lib/glitter.rb"
      
      s3 {
        bucket_name       "my_app"
        access_key        "access"
        secret_access_key "sekret"
      }
    end

    # Leave this in this order to test sorting.    
    @app.assets["3.0"].notes = "I'm the newest and greatest of them all. 3.0 I am!"
    @app.assets["1.0"].notes = "Hi dude, 1.0"
    @app.assets["2.0"].notes = "I'm way better than 2.0"
  end

  it "should have latest" do
    @app.latest.version.should eql("1.0.0")
  end

  # TODO this should be speced out better using moching.
  it "should have head" do
    @app.latest.should respond_to(:head)
  end

  it "should generate rss" do
    REXML::Document.new(@app.appcast.rss).root.attributes["sparkle"].should eql('http://www.andymatuschak.org/xml-namespaces/sparkle')
  end

  shared_examples_for "configuration" do
    it "should read name" do
      @config.name.should eql("My App")
    end

    it "should read version" do
      @config.version.should eql("1.0.0")
    end

    it "should read archive" do
      @config.archive.should eql("my_app.zip")
    end
    
    context "s3" do
      it "should read bucket_name" do
        @config.s3.bucket_name.should eql("my_app")
      end

      it "should read access_key" do
        @config.s3.access_key.should eql("access")
      end

      it "should read secret_access_key" do
        @config.s3.secret_access_key.should eql("sekret")
      end
    end

    it "should have a valid Glitterfile template path" do
      File.exists?(Glitter::App::TemplatePath).should be_true
    end
  end
  
  context "block configuration" do
    before(:all) do
      @config = Glitter::App.configure do
        name          "My App"
        version       "1.0.0"
        archive       "my_app.zip"

        s3 {
          bucket_name       "my_app"
          access_key        "access"
          secret_access_key "sekret"
        }
      end
    end
    
    it_should_behave_like "configuration"
  end

  context "file configuration" do
    before(:all) do
      @config = Glitter::App.configure File.expand_path('../../../lib/glitter/templates/Glitterfile', __FILE__)
    end
    
    it_should_behave_like "configuration"
  end
  
end