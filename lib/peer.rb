require "message"

module Tori
  class Peer
    attr_accessor :ip, :port, :peer_id
    def initialize(ip, port, peer_id=nil)
      @ip        = ip
      @port      = port
      @peer_id   = peer_id
      @connected = false
    end

    def connect(handhake)
      begin
        timeout(10) { @connection = TCPSocket.new(@ip, @port) }
        #puts "#{@ip}:#{@port} CONNECTING"
        @connected = true
        @connection.write(handhake)
        pstrlen   = @connection.read(1)
        pstr      = @connection.read(19)
        reserved  = @connection.read(8)
        info_hash = @connection.read(20)
        peer_id   = @connection.read(20)

        response  = {
          pstr:      pstr,
          pstrlen:   pstrlen,
          reserved:  reserved,
          info_hash: (info_hash.nil? || info_hash.unpack("M*")[0]),
          peer_id:   (peer_id.nil? || peer_id.unpack("M*")[0])
        }
        response
      rescue
        puts "#{@ip}:#{@port} FAILED -> #{$!}"
      end
    end

    def send(message)
      @connection.write(message.content)
      data = nil
      timeout(120) { data = @connection.recv(1024) }
      p "raw data: #{data}"
      parse_response(data)
    rescue Exception => e
      "peer is taking too fucking long... #{e}"
    end

    def close_connection
      @connection.close
    end

    def connected?
      @connected
    end

    private
    def parse_response(byte_stream)
      return nil if byte_stream.nil?
      messages = []

      # ("a4") First 4 bytes are the length of the message
      # ("a")  The 5th byte is the id of the message
      # ("a*") The rest of the message is the payload
      chunked_byte_stream = byte_stream.unpack("a4aa*")

      # The length of the message without the 4 bytes of the length field, "it doesn't count itself"
      len = chunked_byte_stream[0].unpack("N").first

      id = chunked_byte_stream[1].unpack("C").first
      payload = chunked_byte_stream[2]
      message = Message.new({length: len, id: id, payload: payload})
      p "parsed data: #{message}"
      messages << message

      # Since there's no guarantee that messages will come in discrete packets containing only a single entire message,
      # we need to repeat the chuncking process with the message chunk we just got, to check if the peer is sending
      # more messages in a single byte stream.

      # We dividing the stream in 2 parts, the first part contains the first message
      # the scond part contains the remainding (if there's a remainding) of the message.
      # We adding the 4  bytes missing to get the whole message including the length field
      #chunked_messages = byte_stream.unpack "a#{len + 4}a*"

      ## Parse the remainding of the message to if we found one
      #unless chunked_messages[1].empty?
      #  p "chunked message: #{chunked_messages[1]}"
      #  messages << parse_response(chunked_messages[1]) # Add messages
      #end

      #messages
    end
  end
end
