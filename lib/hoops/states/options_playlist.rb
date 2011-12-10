module Hoops
  class OptionsPlaylist < Gui
    MAX_FILE_NAME_LENGTH = 30

    def initialize
      super

      @button_options = { font_size: 32, justify: :center, width: 175 }

      vertical spacing: 30, padding: 20 do
        label "User-defined tracks"
        track_list
        buttons
      end

      @add_track = false

      on_input(:escape) { pop_game_state }
    end

    def setup
      if @add_track and @add_track.track
        @playlist[:tracks] = @playlist[:tracks] << @add_track.track
        populate_track_grid
        @add_track = false
      end

      super
    end

    def track_list
      @playlist = Settings.new(Difficulty::PLAYLIST_CONFIG_FILE)

      scroll_window width: $window.width - 40, height: $window.height * 0.6 do
        @track_grid = grid num_columns: 3, spacing: 8
        populate_track_grid
      end
    end

    def buttons
      horizontal spacing: 20 do
        button("Back", @button_options) { pop_game_state }
        button "Add track...", @button_options.merge(tip: "Add a track from your computer to use in the game") do
          @add_track = AddTrack.new
          push_game_state @add_track
        end
      end
    end

    def populate_track_grid
      @track_grid.clear

      @playlist[:tracks].each_with_index do |track, i|
        name = File.basename(track[:file]).tr('_', ' ')
        name.chomp! File.extname(track[:file])
        name = "#{name[0...(MAX_FILE_NAME_LENGTH - 3)]}..." if name.length > MAX_FILE_NAME_LENGTH
        @track_grid.label name, font_size: 20, tip: track[:file]
        @track_grid.label "(#{track[:duration]})", font_size: 20

        # Can only delete tracks we've added manually.
        @track_grid.button "Remove", font_size: 20, tip: "Remove the file from Hoops playlist; does NOT delete the file" do
          @playlist[:tracks] -= [track]
          populate_track_grid
        end
      end
    end
  end
end