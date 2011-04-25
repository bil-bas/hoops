module Hoops
  class Gui < Fidgit::GuiState
    def initialize
      super

      self.cursor.image = Image["cursor_5x5.png"]
      self.cursor.factor = $window.sprite_scale
    end

    def draw
      $window.scale(1.0 / $window.sprite_scale) { super }
    end
  end
end