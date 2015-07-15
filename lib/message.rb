module Tori
    class Message
	attr_reader :content, :len, :id, :payload
	TYPES = {
	    keep_alive:     { len: "\0\0\0\0", id:  nil, payload: nil },
	    choke:          { len: "\0\0\0\1", id: "\0", payload: nil },
	    unchoke:        { len: "\0\0\0\1", id: "\1", payload: nil },
	    interested:     { len: "\0\0\0\1", id: "\2", payload: nil },
	    not_interested: { len: "\0\0\0\1", id: "\3", payload: nil },
	    have:           { len: "\0\0\0\5", id: "\4", payload: nil },

	    bitfield:       { len: "\0\0\0\1", id: 3, payload: nil },
	    request:        { len: "\0\0\0\1", id: 3, payload: nil },
	    piece:          { len: "\0\0\0\1", id: 3, payload: nil },
	    cancel:         { len: "\0\0\0\1", id: 3, payload: nil },
	    port:           { len: "\0\0\0\1", id: 3, payload: nil }
	}

	def initialize(type)
	    if Message::TYPES.has_key? type
		@len = Message::TYPES[type][:len]
		@id = Message::TYPES[type][:id]
		@payload = Message::TYPES[type][:payload]
	    else
		raise "Invalid Message type"
	    end
	    @content = "#{len}#{id}#{payload}"
	end
    end
    def parse(string)
    end
end
