require 'forwardable'

require_relative "track"

module Hoops
  class Tracklist
    extend Forwardable
    include Enumerable

    PLAYLIST_CONFIG_FILE = "playlist.yml"

    def_delegators :@tracks, :[], :each, :size

    def remove(track)
      @tracks.delete track
      save
    end

    def add(track)
      @tracks <<  track
      save
    end

    alias_method :<<, :add

    def initialize
      @settings = Settings.new(PLAYLIST_CONFIG_FILE)

      game_tracks = Dir[File.join(EXTRACT_PATH, "media", "music", "*.ogg")].map do |track_file|
        Track.new(track_file, user: false)
      end

      user_tracks = (@settings[:tracks]).select {|t| File.exists? t[:file] }
      user_tracks.map! {|t| Track.new(t[:file], t.merge(user: true)) }
      user_tracks.sort_by! {|t| t.name.downcase }

      @tracks = game_tracks + user_tracks
    end

    def save
      @settings[:tracks] = @tracks.select(&:user?).map(&:to_data)
    end
  end
end