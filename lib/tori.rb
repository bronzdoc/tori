require "tori/version"
require "torrent"
require "client"


module Tori
    def self.client torrent_file
	torrent = Tori::Torrent.new torrent_file
	Tori::Client.new torrent
    end

    class TorrentError < StandardError
    end
end
