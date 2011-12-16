require_relative "gui"

module Hoops
  # Add a track to the list of user-defined tracks used by the game.
  class AddTrack < Gui
    attr_reader :track

    def initialize
      super

      on_input(:escape) { pop_game_state }

      @button_options = { font_size: 32, justify: :center, width: 100 }

      vertical padding: 8 do
        label "Browse to an Ogg Vorbis music file (*.ogg)"

        @@current_path ||= Dir.pwd

        file_browser :open, width: $window.width - 32, margin: 0, directory: @@current_path, pattern: "*.ogg" do |sender, result, file|
          case result
            when :open
              name = File.basename(file).tr('_', ' ')
              name.chomp! File.extname(file)

              # Todo: Feedback if format is incorrect.
              @track = Track.new(file, user: true)
              @@current_path = sender.directory
              pop_game_state

            when :cancel
              @track = nil
              pop_game_state setup: false
          end
        end
      end
    end
  end
end