module Tori
    class Peer
	attr_accessor  :ip, :port, :peer_id
	def initialize(ip, port, peer_id=nil)
	    @ip = ip
	    @port = port
	    @peer_id = peer_id
	end
    end
end
