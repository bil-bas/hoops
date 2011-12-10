module Hoops
  # Add a track to the list of user-defined tracks used by the game.
  class AddTrack < Gui
    attr_reader :track

    def initialize
      super

      on_input(:escape) { pop_game_state }

      @button_options = { font_size: 32, justify: :center, width: 160 }

      vertical padding: 0 do
        file_browser :open, width: $window.width - 40, directory: ROOT_PATH, pattern: "*.ogg" do |sender, result, file|
          case result
            when :open
              name = File.basename(file).tr('_', ' ')
              name.chomp! File.extname(file)

              # Todo: Feedback if format is incorrect.
              if @duration.text.strip =~ /^(\d+:\d{2})$/
                @track = { name: name, file: file, duration: $1 }
                pop_game_state
              end

            when :cancel
              @track = nil
              pop_game_state setup: false
          end
        end

        horizontal spacing: 20 do
          label "Duration (M:SS):", tip: "Duration of track in minutes and seconds, such as '3:25'"
          @duration = text_area text: '3:00', max_height: 30, width: $window.width / 2
        end

        horizontal spacing: 20 do
          button("Cancel", @button_options) do
            @track = nil
            pop_game_state
          end
        end
      end
    end
  end
end