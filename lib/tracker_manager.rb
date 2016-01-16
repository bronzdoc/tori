require "udp_tracker"
require "http_tracker"

module Tori
  module TrackerManager
    def self.build(url)
      announce = URI(url)

      case announce.scheme
      when "udp"
        Tori::UDPTracker.new(url)
      when "http"
        Tori::HTTPTracker.new(url)
      else
        raise TrackerProtocolError, "Can't get peers from #{tracker} no support for #{tracker.scheme} protocol."
      end
    end
  end
end
