module Hoops
  class Difficulty < Gui
    def initialize
      super

      pack :vertical do
        options = { width: $window.retro_width - 60, font_size: 32, justify: :center }
        button("Easy", options) { push_game_state(Play.new(:easy)) }
        button("Normal", options) { push_game_state(Play.new(:normal)) }
        button("Awesome", options) { push_game_state(Play.new(:hard)) }
      end

      on_input(:escape) { pop_game_state }
    end
  end
end