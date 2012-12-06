require_relative "gui"

require_relative "../objects/spinning_hoop"

module Hoops
  class Menu < Gui

    TITLE_COLOR = Color.rgb(50, 120, 255)
    def initialize
      super

      add_inputs(
          p: :play,
          e: :close,
          escape: :close
      )

      Log.level = settings[:debug_mode] ? Logger::DEBUG : Logger::INFO

      vertical align_h: :center, spacing: 10, padding: 15 do
        vertical align_h: :center, spacing: 0, padding: 0 do
          label "An indeterminate number of", font_height: 40, padding_bottom: -20, color: TITLE_COLOR, align_h: :center, justify: :center
          label "HOOPS!", font_height: 140, color: TITLE_COLOR, align_h: :center, justify: :center
          label "by Spooner", color: TITLE_COLOR, align_h: :center, justify: :center
        end

        vertical align_h: :center, spacing: 12, padding: 0, padding_top: 10 do
          options = { width: 225, font_height: 30, justify: :center }
          button("Play", options.merge(tip: 'Both players on the same keyboard')) { play }
          button("User tracks", options.merge(tip: "Add or remove .ogg music tracks to the playlist")) { push_game_state OptionsPlaylist }
          #button("About", options.merge(enabled: false))
          button("Exit", options) { close }
        end
      end
      @hoops = []
      (10..90).step(12) do |x|
        @hoops << SpinningHoop.new(x: x, y: 56, color: Color.rgb(rand(255), rand(255), rand(255)))
      end
    end


    def draw
      super
      @hoops.each(&:draw)
    end

    def update
      super
      @hoops.each(&:update)
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
