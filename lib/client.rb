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
	    @active_peers = []
	end

	def download
	    connect_to_peers
	    @active_peers.each do |peer|
	    end
	end

	def upload
	end

	private
	def connect_to_peers
	    @torrent.peers.each do |peer|
		handshake_response = peer.connect handshake
		if handshake_response && handshake_response[:info_hash] != @torrent.info_hash
		    disconnect peer
		else
		    @active_peers << peer
		end

	        #TODO Remove this, only for testing
		break if @active_peers.size > 0
	    end
	end

	def handshake
	    pstr = "BitTorrent protocol"
	    pstrlen = [pstr.size].pack "C*"
	    reserved = "\x00\x00\x00\x00\x00\x00\x00\x00"
	    info_hash = @torrent.info_hash
	    peer_id = @torrent.peer_id
	    message = "#{pstrlen}#{pstr}#{reserved}#{info_hash}#{peer_id}"

	    message
	end

	def disconnect(peer)
	    peer.connection.close
	end

	def send_message peer
	    peer.connection.write
	end
    end
end
