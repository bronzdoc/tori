require "tracker"

module Tori
  class UDPTracker < Tracker
    attr_reader :udp_socket

    def initialize(torrent)
      super(torrent)
      @udp_socket = UDPSocket.new
    end

    def peers
      announce
      super
    end

    private
    ## Packet to request tracker for a connection id
    def request_connection_id
      # Offset   | Size               | Name           | Value
      # -----------------------------------------------------------------------
      # 0        | 8 (64 bit integer) | connection id  | for this request, the initial value 0x41727101980
      # 8        | 4 (32-bit integer) | action  0 for  | connection request
      # 12       | 4 (32-bit integer) | transaction id | a random number created by client
      first_32_bit_conn_id = 0x41727101980 >> 32
      second_32_bit_conn_id = 0x41727101980 & 0xffffffff

      buffer = [first_32_bit_conn_id, second_32_bit_conn_id, 0, 16].pack "N*"
      c0, c1, action, @client_transaction_id = buffer.unpack "N*"
      @udp_socket.send buffer, 0, @tracker.host, @tracker.port

      ## Tracker response
      # Offset |  Size               | Name            | Value
      #------------------------------------------------------------------------
      # 0      |  4 (32-bit integer) | action          | 0 for connect response
      # 4      |  4 (32-bit integer) | transaction id  | same like request's transaction id.
      # 8      |  8 (64 bit integer) | connection id   | a connection id that must be acceptable for at least 2 minutes from source
      res = udp_socket.recvfrom(5000)
      res_action, @res_transaction_id, @res_connection_id = res[0].unpack "NNQ"
    end

     ## Client Announce
    def announce
      request_connection_id

      # Offset | Size                | Name            | Value
      # ----------------------------------------------------------------------
      # 0      |  8 (64 bit integer) | connection id   | connection id from server
      # 8      |  4 (32-bit integer) | action          | 1; for announce request
      # 12     |  4 (32-bit integer) | transaction id  | client can make up another transaction id...
      # 16     |  20                 | info_hash       | the info_hash of the torrent that is being announced
      # 36     |  20                 | peer id         | the peer ID of the client announcing itself
      # 56     |  8 (64 bit integer) | downloaded      | bytes downloaded by client this session
      # 64     |  8 (64 bit integer) | left            | bytes left to complete the download
      # 72     |  8 (64 bit integer) | uploaded        | bytes uploaded this session
      # 80     |  4 (32 bit integer) | event           | 0=None; 1=Download completed; 2=Download started; 3=Download stopped.
      # 84     |  4 (32 bit integer) | IPv4            | IP address, default set to 0 (use source address)
      # 88     |  4 (32 bit integer) | key             | ?
      # 92     |  4 (32 bit integer) | num want        | -1 by default. number of clients to return
      # 96     |  2 (16 bit integer) | port            | the client's TCP port
      client_announce = [
        @res_connection_id,
        0x1,
        @client_transaction_id,
        @options[:info_hash],
        @options[:peer_id],
        0x0,
        0x1,
        @options[:left],
        0x0,
        0x0,
        0x0,
        0x0,
        0x0,
        0x32,
        @options[:port]
      ].pack("Q<NNA20A20NNQ<NNNNNNS")

      # Check if the transaction id match with the transaction_id of the response
      if valid_transaction_id?
        # If a response is not received after 15 * 2 ^ n seconds, the client should retransmit the request,
        # where n starts at 0 and is increased up to 8 (3840 seconds) after every retransmission.
        # Note that it is necessary to rerequest a connection ID when it has expired.
        0.upto 8 do |n|
          begin
            @udp_socket.send client_announce, 0, @tracker.host, @tracker.port
            res = @udp_socket.recvfrom(5000)
            @response = res[0].unpack("N5A*")
            break
          rescue
            p "Connection timed out... reconnecting with tracker"
          end
        end
      end
      @peers = @response[5]
    end

    def valid_transaction_id?
      @res_transaction_id == @client_transaction_id
    end
  end
end
