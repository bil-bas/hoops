module Hoops
  class GameOver < Gui
    TEXT_COLOR = Color.rgba(255, 255, 255, 180)

    def initialize
      super
      on_input(:escape) { game_state_manager.pop_until_game_state Menu }

      @font = Font["pixelated.ttf", 100]
    end

    def draw
      previous_game_state.draw

      $window.scale(1.0 / $window.sprite_scale) do
        @font.draw_rel "Game Over!", $window.width / 2, $window.height / 2, ZOrder::GUI, 0.5, 0.5, 1, 1, TEXT_COLOR
      end

      super
    end
  end
end