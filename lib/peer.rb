module Tori
    class Peer
	attr_accessor  :ip, :port, :peer_id, :connection, :connected
	def initialize(ip, port, peer_id=nil)
	    @ip = ip
	    @port = port
	    @peer_id = peer_id
	    @connected = false
	end

	def connect(handhake)
	    begin
		@connection = TCPSocket.new @ip, @port
		can_read, can_write = IO.select [@connection], [@connection], nil, 4
		if can_read && can_write
		    p "#{@ip}:#{@port} CONNECTED"
		    @connected = true
		    @connection.write handhake
		    response = {
			pstr:      @connection.read(1),
			pstrlen:   @connection.read(19),
			reserved:  @connection.read(8),
			info_hash: @connection.read(20).unpack("M*")[0],
			peer_id:   @connection.read(20).unpack("M*")[0]
		    }
		    response
		else
		    raise
		end
	    rescue
		p "#{@ip}:#@port} FAILED -> #{p $!}"
	    end
	end

	def connected?
	    @connected
	end
    end
end
