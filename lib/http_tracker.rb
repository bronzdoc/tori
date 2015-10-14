require "tracker"

module Tori
  class HTTPTracker < Tracker
    def  initialize(torrent)
      super(torrent)
    end

    def peers
      request_tracker
      super
    end

    private
    def request_tracker
      @tracker.query = URI.encode_www_form(@options)
      res = Net::HTTP.get_response(@tracker)
      @response = BEncode::Parser.new(res.body).parse!
      @peers = @response["peers"]
    end
  end
end
