require "udp_tracker"
require "http_tracker"

module Tori
  module TrackerManager
    def self.build(torrent)
      announce = URI torrent.announce
      if announce.scheme == "udp"
        Tori::UDPTracker.new torrent
      elsif announce.scheme == "http"
        Tori::HTTPTracker.new torrent
      else
        raise TrackerProtocolError, "Can't get peers from #{tracker} no support for #{tracker.scheme} protocol."
      end
    end
  end
end
