module Hoops
  class Gui < Fidgit::GuiState
    BACKGROUND_COLOR = Color.rgb(50, 50, 100)

    def initialize
      super

      self.cursor.image = Image["cursor_5x5.png"]
      self.cursor.factor = $window.sprite_scale
    end

    def draw
      $window.scale(1.0 / $window.sprite_scale) do
        $window.pixel.draw(0, 0, ZOrder::BACKGROUND, $window.width, $window.height, BACKGROUND_COLOR)
        super
      end
    end
  end
end