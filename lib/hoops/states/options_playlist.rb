module Hoops
  class OptionsPlaylist < Gui
    MAX_FILE_NAME_LENGTH = 50

    def initialize
      super

      @button_options = { font_size: 32, justify: :center, width: 175 }

      vertical spacing: 20, padding: 20 do
        label "Tracklist"
        track_list
        buttons
      end

      @add_track = nil

      on_input(:escape) { pop_game_state }
    end

    def setup
      if @add_track
        unless @playlist.include? @add_track.track
          @playlist << @add_track.track
          populate_track_grid
        end

        @add_track = nil
      end

      super
    end

    def track_list
      @playlist = Tracklist.new

      scroll_window width: $window.width - 40, height: $window.height * 0.75 do
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

      @playlist.each do |track|
        name = track.name
        name = "#{track.name[0...(MAX_FILE_NAME_LENGTH - 3)]}..." if track.name.length > MAX_FILE_NAME_LENGTH
        @track_grid.label name, font_size: 20, tip: track.file, width: $window.width - 250, color: track.user? ? Color::WHITE : Color::GRAY
        @track_grid.label "(#{track.duration_string})", font_size: 20, color: track.user? ? Color::WHITE : Color::GRAY

        # Can only delete tracks we've added manually.
        if track.user?
          @track_grid.button "Remove", font_size: 20, tip: "Remove the file from Hoops playlist; does NOT delete the file" do
            @playlist.remove track
            populate_track_grid
          end
        else
          @track_grid.label ""
        end
      end
    end
  end
end