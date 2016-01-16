module Tori
  class Torrent
    attr_reader :trackers, :info_hash

    def initialize(torrent_file=nil)
      raise Tori::TorrentError if torrent_file.nil?

      bencoded_stream = File.open(File.expand_path(torrent_file)).read
      @metadata = parse(bencoded_stream)

      @trackers = []
      @metadata["announce-list"].each do |announce|
        @trackers << Tori::TrackerManager.build(announce.first) unless announce.first.nil?
      end

      @info_hash = Digest::SHA1.digest(@metadata["info"].bencode)
    end

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

    private
    def parse(stream)
      BEncode::Parser.new(stream).parse!
    end
  end
end
