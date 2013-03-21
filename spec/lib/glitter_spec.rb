require 'spec_helper'
require 'rexml/document'

describe Glitter do
  let(:server) do
    Glitter::Server.new
  end

  it "should release to channel" do
    server.channel('test-channel').release do
      version "1.1.2-#{rand}"
      notes   %[Hey man, this is pretty awesome.]
      asset   File.open(__FILE__)
    end.push.head
  end
end
