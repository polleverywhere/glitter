require 'spec_helper'
require 'rexml/document'

describe Glitter do
  let(:server) do
    Glitter::Server.new
  end

  it "should release to channel" do
    Glitter::Release::Sparkle.new server.channel('test-channel'), "1.1.2-#{rand}" do |r|
      r.notes = %[Hey man, this is pretty awesome.]
      r.asset = File.open(__FILE__)
    end.push.head
  end
end
