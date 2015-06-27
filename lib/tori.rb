require "tori/version"
require "net/http"
require "socket"
require "date"
require "bencode"
require "digest"

module Tori
    class Torrent
	attr_reader :metadata, :announce

	def initialize(torrent_file=nil)
	     raise Tori::TorrentError if torrent_file.nil?
             bencoded_stream = File.open(File.expand_path(torrent_file)).read
	     @metadata = parse bencoded_stream
	     @announce = @metadata["announce"]
	end

	def peers
	    params = {
		# URL encoded 20-byte SHA1 hash of the value of the info key from the Metainfo file.
		# Note that the value will be a bencoded dictionary,
		info_hash:  Digest::SHA1.digest(@metadata["info"].bencode),

		# URL encoded 20-byte string used as a unique ID for the client,
		# generated by the client at startup. This is allowed to be any value, and may be binary data.
		peer_id:    Digest::SHA1.digest("#{Process.pid}#{DateTime.now}"),

		# Ports reserved for BitTorrent are typically 6881-6889.
		port:       6885,

		# The total amount uploaded (since the client sent the 'started' event to the tracker) in base ten ASCII.
		# this should be the total number of bytes uploaded.
		uploaded:   0,

		# The total amount downloaded (since the client sent the 'started' event to the tracker) in base ten ASCII.
		# this should be the total number of bytes downloaded.
		downloaded: 0,

		# The number of bytes needed to download to be 100% complete and get all the included files in the torrent.
		left:      length,

		#indicates that the client accepts a compact response (1 is yes, 0 is no).
		compact:    1,

		# Indicates that the tracker can omit peer id field in peers dictionary. This option is ignored if compact is enabled.
		no_peer_id: 0,

		# event: If specified, must be one of started, completed, stopped
		# If not specified, then this request is one performed at regular intervals.
		   # started: The first request to the tracker must include the event key with this value.
		   # stopped: Must be sent to the tracker if the client is shutting down gracefully.
		   # completed: Must be sent to the tracker when the download completes. However, must not be sent if the download was already 100% complete when the client started. Presumably, this is to allow the tracker to increment the "completed downloads" metric based solely on this event
		event:      "started"
	    }

	    tracker = URI @announce
	    tracker = URI "http://#{tracker.host}#{tracker.path}" if tracker.scheme == "udp"

	    tracker.query = URI.encode_www_form(params)
	    res = Net::HTTP.get_response(tracker)
	    tracker_response = BEncode::Parser.new(res.body).parse! #if res.is_a?(Net::HTTPSuccess)

	    peers = tracker_response["peers"]

	    # Divide byte string into 6 byte chunks
	    peer_ips_hex = []
	    peers.scan(/.{6}/).each { |byte| peer_ips_hex << byte.unpack("H*").first }

	    # Parse ip and port and store it
	    # NOTE the ip is the first four bytes the reminding 2 combined is the port
	    peer_ips = []
	    peer_ips_hex.each do |hex_ip|
		byte_divided_ip = hex_ip.scan(/.{2}/)
		ip_segment = 4.times.map {|i| byte_divided_ip[i].to_i(16).to_s 10}
		port = "#{byte_divided_ip[3]}#{byte_divided_ip[4]}".to_i(16).to_s 10
		peer_ips << "#{ip_segment[0]}.#{ip_segment[1]}.#{ip_segment[2]}.#{ip_segment[3]}:#{port}"
	    end
	    peer_ips
	end

        private
	def length
	    length = 0
            info = @metadata["info"]
	    if info.has_key? "length"
		length = info["length"]
	    else
		info["files"].each {|file| length += file["length"]}
	    end
	    length
	end

	def parse(stream)
	    BEncode::Parser.new(stream).parse!
	end
    end

    class Client
	attr_reader :torrent
	def initialize torrent_obj
	    @torrent = torrent_obj
	end

	def self.connect
	    @torrent.peers.each do |peer|
		Net::HTTP.get peer
	    end
	end
    end

    class TorrentError < StandardError
    end

end
