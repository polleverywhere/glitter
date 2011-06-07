require 'spec_helper'
require 'rexml/document'

describe Glitter::Release do
  before(:all) do
    @release = Glitter::Release.new Glitter::Configuration.configure {
      name          "My App"
      version       "1.0.0"
      archive       "lib/glitter.rb"
      release_notes "http://myapp.com/release_notes/"

      s3 {
        bucket            "my_app"
        access_key        "access"
        secret_access_key "sekret"
      }
    }
  end

  it "should have name" do
    @release.name.should eql("My App 1.0.0")
  end

  it "should generate rss entry" do
    REXML::Document.new(@release.to_rss).root.attributes["sparkle"].should eql('http://www.andymatuschak.org/xml-namespaces/sparkle')
  end

  it "should have object_name" do
    @release.object_name.should eql("my-app-1.0.0.rb")
  end
end

describe Glitter::Configuration do

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

    it "should read release notes" do
      @config.release_notes.should eql("http://myapp.com/release_notes/")
    end

    context "s3" do
      it "should read bucket" do
        @config.s3.bucket.should eql("my_app")
      end

      it "should read access_key" do
        @config.s3.access_key.should eql("access")
      end

      it "should read secret_access_key" do
        @config.s3.secret_access_key.should eql("sekret")
      end
    end

    it "should have a valid Glitterfile template path" do
      File.exists?(Glitter::Configuration::TemplatePath).should be_true
    end
  end

  context "block configuration" do
    before(:all) do
      @config = Glitter::Configuration.configure do
        name          "My App"
        version       "1.0.0"
        archive       "my_app.zip"
        release_notes "http://myapp.com/release_notes/"

        s3 {
          bucket            "my_app"
          access_key        "access"
          secret_access_key "sekret"
        }
      end
    end
    
    it_should_behave_like "configuration"
  end

  context "file configuration" do
    before(:all) do
      @config = Glitter::Configuration.configure File.expand_path('../../../lib/glitter/templates/Glitterfile', __FILE__)
    end
    
    it_should_behave_like "configuration"
  end
  
end