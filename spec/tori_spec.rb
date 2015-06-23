require 'spec_helper'
require 'tori'

RSpec.describe "Tori" do
    describe "Torrent", "#new" do
	it "should raise Tori::TorrentError if nill is passed" do
	    expect { Tori::Torrent.new nil}.to raise_error(Tori::TorrentError)
	end
    end

    describe "Torrent", "#torrent" do
	it "should be a hash" do
	    t = Tori::Torrent.new "spec/fixtures/test.torrent"
	    expect(t.torrent.class).to eq(Hash)
	end
    end
end


