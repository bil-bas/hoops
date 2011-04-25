module Hoops
  class Play < GameState
    trait :timer

    SONGS = {
        "Simply dance - Libra.ogg" => (4 * 60) + 5,
    }

    SONG_VOLUME_FULL = 0.25
    SONG_VOLUME_MUTED = 0.05

    def initialize(difficulty)
      super()

      middle = (($window.retro_width - 1) / 2.0)
      @player1 = Player.create(0, difficulty, x: middle - 8, y: 25)
      @player2 = Player.create(1, difficulty, x: middle + 8, y: 25)

      @background_image = TexPlay.create_image($window, $window.width / $window.sprite_scale,
                                               $window.height / $window.sprite_scale, color: [0.1, 0.45, 0.7, 1])

      Command::Y_POSITIONS.each_value do |y|
        Fire.create(x: $window.retro_width / 2, y: y)
        Fire.create(x: $window.retro_width / 2, y: y + 3.5)
      end

      on_input(:escape) { pop_game_state }
      @song_name = SONGS.keys.sample
      @song = Song[@song_name]
      @song.volume = SONG_VOLUME_FULL
      @song.pause
    end

    def setup
      @song.play
    end

    def finalize
      @song.pause
    end

    def mute_song(duration)
      @song.volume = SONG_VOLUME_MUTED
      after(duration, name: :unmute) { @song.volume = SONG_VOLUME_FULL }
    end

    def draw
      super
      @background_image.draw(0, 0, ZOrder::BACKGROUND)
    end

    def update
      if @song.playing?
        super
      else
        push_game_state GameOver
      end
    end
  end
end