module Tori
  class Message
    attr_reader :content, :length, :id, :payload, :type

    TYPES = [
      ## keep-alive: <len=0000>
      # The keep-alive message is a message with zero bytes,
      # specified with the length prefix set to zero. There is no message ID and no payload.
      :keep_alive,     #{ len: 0x0000, id: nil, payload: nil },

      ## choke: <len=0001><id=0>
      # The choke message is fixed-length and has no payload.
      :choke,          #{ len: 0x0001, id: 0, payload: nil },

      ## unchoke: <len=0001><id=1>
      # The unchoke message is fixed-length and has no payload.
      :unchoke,        #{ len: 0x0001, id: 1, payload: nil },

      ## interested: <len=0001><id=2>
      # The interested message is fixed-length and has no payload.
      :interested,     #{ len: 0x0001, id: 2, payload: nil },

      ## not interested: <len=0001><id=3>
      # The not interested message is fixed-length and has no payload
      :not_interested, #{ len: 0x0001, id: 3, payload: nil },

      ## have: <len=0005><id=4><piece index>
      # The have message is fixed length.
      # The payload is the zero-based index of a piece that has just been successfully downloaded
      # and verified via the hash.
      :have,           #{ len: 0x0005, id: 4, payload: nil },

      ## bitfield: <len=0001+X><id=5><bitfield>
      # The bitfield message may only be sent immediately after the handshaking sequence is completed,
      # and before any other messages are sent.
      # It is optional, and need not be sent if a client has no pieces.
      :bitfield,       #{ len: 0x0001, id: 5, payload: nil },

      ## request: <len=0013><id=6><index><begin><length>
      # The request message is fixed length, and is used to request a block. The payload contains the following information:
      #    * index:  integer specifying the zero-based piece index
      #    * begin:  integer specifying the zero-based byte offset within the piece
      #    * length: integer specifying the requested length.
      :request,        #{ len: 0x0013, id: 6, payload: nil },

      ## piece: <len=0009+X><id=7><index><begin><block>
      # The piece message is variable length, where X is the length of the block. The payload contains the following information:
      #    * index: integer specifying the zero-based piece index
      #    * begin: integer specifying the zero-based byte offset within the piece
      #    * block: block of data, which is a subset of the piece specified by index.
      :piece,          #{ len: 0x0009, id: 7, payload: nil },

      ## cancel: <len=0013><id=8><index><begin><length>
      # The cancel message is fixed length, and is used to cancel block requests.
      # The payload is identical to that of the "request" message.
      :cancel,         #{ len: 0x0013, id: 8, payload: nil },

      ## port: <len=0003><id=9><listen-port>
      # The port message is sent by newer versions of the Mainline that implements a DHT tracker.
      # The listen port is the port this peer's DHT node is listening on.
      # This peer should be inserted in the local routing table (if DHT tracker is supported).
      :port            #{ len: 0x0003, id: 9, payload: nil }
    ]

    def self.build(config = { len: nil, id: nil, payload: nil })
      type =
        case config[:id]
        when 0
          :keep_alive
        when 1
          :choke
        when 2
          :unchoke
        when 3
          :interested
        when 4
          :not_interested
        when 5
          :have
        end

      self.new(type, config)
    end

    def initialize(config = { length: nil, id: nil, payload: nil })
      type =
        case config[:id]
        when 0
          :keep_alive
        when 1
          :choke
        when 2
          :unchoke
        when 3
          :interested
        when 4
          :not_interested
        when 5
          :have
        end

      raise "Invalid Message type" unless Message::TYPES.include?(type)

      @length     = config[:length]
      @id         = config[:id]
      @payload    = config[:payload]
      @type       = type

      @content    = "#{@length}#{@id}#{@payload}"
    end

    #def initialize
    #  raise "Invalid Message type" unless Message::TYPES.has_key? args
    #  @len     = Message::TYPES[args][:len]
    #  @id      = Message::TYPES[args][:id]
    #  @payload = Message::TYPES[args][:payload]
    #  @type    = args
    #  @content = "#{@len}#{@id}#{@payload}"
    #end
  end
end
