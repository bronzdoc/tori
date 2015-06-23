require "tori/version"
require "net/http"
require "date"
require "bencode"
require "digest"

module Tori
    class Torrent
	attr_reader :announce, :info, :peers

	def initialize(torrent_file=nil)
	     raise Tori::TorrentError if torrent_file.nil?

             bencoded_stream = File.open(File.expand_path(torrent_file)).read
	     parsed_bencode = parse bencoded_stream
	     @announce = parsed_bencode["annonce"]
	     @info = parsed_bencode["info"]
	     @peers = get_peers
	end

        private
	def get_peers
	    tracker = URI.new "#{@anounce}"
	    params = {
		info_hash: Digest::SHA1.hexdigest @info.bencode,
		peer_id:   Digest::MD5.hexdigest "#{Process.pid}#{Datetime.now}",
		port:      6885,

	    }
	    peers = Net::HTTP.get tracker
	end

	def parse(stream)
	    BEncode::Parser.new(stream).parse!
	end
    end

    def self.connect tracker
	get_peers trakcer
    end

    def get_peers torrent
    end

    class TorrentError < StandardError
    end

end
