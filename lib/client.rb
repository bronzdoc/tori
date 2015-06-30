require "torrent"

module Tori
    class Client
	attr_reader :torrent, :active_peers, :state
	def initialize torrent_obj
	    @torrent = torrent_obj
	    @state = {
		am_choking:      1, #this client is choking the peer
		am_interested:   0, #this client is interested in the peer
		peer_choking:    1, #peer is choking this client
		peer_interested: 0  #peer is interested in this client
	    }
	end

	def download
	end

	def upload
	end

	private
	def connect(&block)
	    @torrent.peers.each do |peer|
		begin
		    connected_with_peer? = handshake peer
		    Thread.new do
			socket.write message
			p socket.read 1
			p socket.read 19
			p socket.read 8
			p socket.read(20).unpack "a*"
			p socket.read(20).unpack "a*"
		    end
		rescue
		    p $!
		end
	    end
	end

	def handshake(peer)
	    pstr = "BitTorrent protocol"
	    pstrlen =  [pstr.size].pack "C*"
	    reserved = "\x00\x00\x00\x00\x00\x00\x00\x00"
	    info_hash = @torrent.info_hash
	    peer_id = @torrent.peer_id
	    message = "#{pstrlen}#{pstr}#{reserved}#{info_hash}#{peer_id}"

	    socket = TCPSocket.new peer.ip, peer.port
	    socker.gets
	end
    end
end
