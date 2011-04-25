module Hoops
  class Menu < Gui
    BACKGROUND_COLOR = Color.rgb(50, 50, 100)
    def initialize
      super

      add_inputs(
          p: :play,
          e: :close,
          escape: :close
      )

      Log.level = settings[:debug_mode] ? Logger::DEBUG : Logger::INFO

      pack :horizontal do
        pack :vertical, spacing: 18 do
          heading = label "An indeterminate number of hoops!", font_size: 28, color: Color.rgb(50, 120, 255), width: $window.retro_width, justify: :center

          pack :vertical, spacing: 12, padding_left: 80 do
            options = { width: heading.width - 15 - 160, font_size: 32, justify: :center }
            button("Play", options.merge(tip: 'Both players on the same keyboard')) { play }
            button("Options", options.merge(enabled: false))
            button("About", options.merge(enabled: false))
            button("Exit", options) { close }
          end
        end
      end

     (10..70).step(10) do |x|
        SpinningHoop.create(x: x, y: 50, color: Color.rgb(rand(255), rand(255), rand(255)))
      end
    end


    def draw
      $window.pixel.draw(0, 0, ZOrder::BACKGROUND, $window.width, $window.height, BACKGROUND_COLOR)
      @game_objects.draw
      super
    end

    def setup
      super
      log.info "Viewing main menu"
    end

    def play
      push_game_state Difficulty.new
    end

    def close
      log.info "Exited game"
      super
      exit
    end
  end
end
