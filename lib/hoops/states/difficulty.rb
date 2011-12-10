module Hoops
  class Difficulty < Gui
    PLAYLIST_CONFIG_FILE = "playlist.yml"

    DIFFICULTY_FILE = File.join(EXTRACT_PATH, 'lib', 'hoops', 'difficulty.yml')
    DIFFICULTY_SETTINGS = YAML.load(File.read(DIFFICULTY_FILE))

    def initialize
      super

      @button_options = { font_size: 32, justify: :center, width: 160 }

      @difficulty = []

      vertical padding: 16, spacing: 40, align: :center, width: @container.width, height: @container.height do
        track_selector

        players

        buttons
      end

      on_input(:escape) { pop_game_state }
    end

    def players
      horizontal padding: 0, align_h: :center do
        2.times do |number|
          vertical do
            label "Player #{number + 1}", font_size: 48
            label "Difficulty", font_size: 32
            @difficulty << group do
              vertical spacing: 8 do
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
      horizontal do
        label "Track: "

        vertical do
          @track_random = toggle_button "Random", value: settings[:playlist, :random] do |sender, value|
             @track_choice.enabled = (not value)
          end

          # The tracklist is both the ones that come with the game and any added by the user.
          @tracks = []
          game_tracks = Dir[File.join(EXTRACT_PATH, "media", "music", "*.ogg")]
          game_tracks.each do |track_file|
            track_file = File.basename track_file
            track_file =~ /^(.*) @(\d+)_(\d+).ogg$/
            @tracks << { name: $1, file: track_file, duration: "#{$2}:#{$3}" }
          end

          @tracks += Settings.new(PLAYLIST_CONFIG_FILE)[:tracks]

          selected_track_index = rand(@tracks.size)
          @track_choice = combo_box enabled: (not settings[:playlist, :random]) do

            @tracks.each_with_index do |track, i|
              track_name = track[:name]
              item "#{track_name} (#{track[:duration]})", i
              selected_track_index = i if track[:file] == settings[:playlist, :track]
            end
          end
          @track_choice.value = selected_track_index
        end
      end
    end

    def buttons
      button("Dance!!!", @button_options.merge(align: :center, font_height: 70, width: 300)) do
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

      button("Cancel", @button_options.merge(width: 70)) { pop_game_state }
    end
  end
end