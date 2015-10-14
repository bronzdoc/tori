require "tori/version"
require "torrent"
require "client"


module Tori
  tori_client = nil
  def self.client torrent_file
    torrent = Tori::Torrent.new torrent_file
    Tori::Client.new torrent
  end

  class TorrentError < StandardError
  end

  class TrackerProtocolError < StandardError
  end
end
