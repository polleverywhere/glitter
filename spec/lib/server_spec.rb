require 'spec_helper'
require 'rexml/document'

describe Glitter::Server do
  describe "#new" do
    context "No timeout flag is passed to the server constructor" do
      let(:server) { Glitter::Server.new }

      it "defaults to the default timeout" do
        expect(server.timeout).to eq Glitter::Server::DEFAULT_S3_TIMEOUT
      end
    end

    context "A timeout flag is passed to the server constructor" do
      let(:server) { Glitter::Server.new(timeout: 10) }
      
      it "will have a timeout value of the passed timeout flag" do
        expect(server.timeout).to eq 10
      end
    end
  end
end
