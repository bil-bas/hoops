module Hoops
  class Difficulty < Gui
    PLAYLIST_CONFIG_FILE = "playlist.yml"

    DIFFICULTY_FILE = File.join(EXTRACT_PATH, 'lib', 'hoops', 'difficulty.yml')
    DIFFICULTY_SETTINGS = YAML.load(File.read(DIFFICULTY_FILE))

    def initialize
      super

      @button_options = { font_size: 32, justify: :center, width: 160 }

      @difficulty = []

      pack :vertical, padding: 16, spacing: 40 do
        track_selector

        players

        buttons
      end

      on_input(:escape) { pop_game_state }
    end

    def players
      pack :horizontal, padding: 0 do
        2.times do |number|
          pack :vertical do
            label "Player #{number + 1}", font_size: 48
            label "Difficulty", font_size: 32
            @difficulty << group do
              pack :vertical, spacing: 8 do
                DIFFICULTY_SETTINGS.each_pair do |difficulty, settings|
                  radio_button settings[:name], difficulty, @button_options.merge(font_size: 24)
                end
              end
            end
            @difficulty.last.value = settings[:difficulty, number]
          end
        end
      end
    end

    def track_selector
      pack :horizontal do
        label "Track: "

        pack :vertical do
          @track_random = toggle_button "Random", value: settings[:playlist, :random] do |sender, value|
             @track_choice.enabled = (not value)
          end

          @tracks = Settings.new(PLAYLIST_CONFIG_FILE)[:tracks]
          @tracks.select! {|t| t[:enabled] }
          selected_track_index = rand(@tracks.size)
          @track_choice = combo_box enabled: (not settings[:playlist, :random]), font_size: 24 do

            @tracks.each_with_index do |track, i|
              track_name = track[:file].chomp(File.extname(track[:file])).tr('_', ' ')
              item track_name, i
              selected_track_index = i if track[:file] == settings[:playlist, :track]
            end
          end
          @track_choice.value = selected_track_index
        end
      end
    end

    def buttons
      pack :horizontal, spacing: 20 do
        button("Back", @button_options) { pop_game_state }
        button("Dance!", @button_options) do
          # Save difficulty settings
          2.times do |number|
            settings[:difficulty, number] = @difficulty[number].value
          end

          # Save track settings.
          track = @track_random.value ? @tracks.sample : @tracks[@track_choice.value]
          settings[:playlist, :random] = @track_random.value
          settings[:playlist, :track] = track[:file] unless @track_random.value

          push_game_state Play.new(DIFFICULTY_SETTINGS[@difficulty[0].value],
                                   DIFFICULTY_SETTINGS[@difficulty[1].value], track)
        end
      end
    end
  end
end