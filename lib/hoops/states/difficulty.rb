module Hoops
  class Difficulty < Gui
    DIFFICULTY_FILE = File.join(EXTRACT_PATH, 'lib', 'hoops', 'difficulty.yml')
    DIFFICULTY_SETTINGS = YAML.load(File.read(DIFFICULTY_FILE))

    def initialize
      super

      button_options = { font_size: 32, justify: :center, width: 160 }

      @difficulty = []

      pack :vertical, padding: 0 do
        pack :horizontal, padding: 0 do
          2.times do |number|
            pack :vertical do
              label "Player #{number + 1}", font_size: 48
              label "Difficulty", font_size: 32
              @difficulty << group do
                pack :vertical, spacing: 8 do
                  DIFFICULTY_SETTINGS.each_pair do |difficulty, settings|
                    radio_button settings[:name], difficulty, button_options.merge(font_size: 24)
                  end
                end
              end
              @difficulty.last.value = settings[:difficulty, number]
            end
          end
        end

        pack :horizontal, spacing: 20, padding_top: 100 do
          button("Back", button_options) { pop_game_state }
          button("Dance!", button_options) do
            2.times do |number|
              settings[:difficulty, number] = @difficulty[number].value
            end
            push_game_state Play.new(DIFFICULTY_SETTINGS[@difficulty[0].value],
                                     DIFFICULTY_SETTINGS[@difficulty[1].value])
          end
        end
      end

      on_input(:escape) { pop_game_state }
    end
  end
end