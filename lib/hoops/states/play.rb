module Hoops
  class Play < GameState
    trait :timer

    BACKGROUND_COLOR = Color.rgb(26, 114, 179)

    SONG_VOLUME_FULL = 0.25
    SONG_VOLUME_MUTED = 0.05

    TIME_BAR_THICKNESS = 3
    TIME_COLOR = Color.rgb(0, 80, 140)

    PLAYER_Y = 24

    def initialize(settings1, settings2, track)
      super()

      @track = track

      middle = (($window.retro_width - 1) / 2.0)
      @player1 = Player.create(0, settings1, x: middle - 8, y: PLAYER_Y)
      @player2 = Player.create(1, settings2, x: middle + 8, y: PLAYER_Y)

      @background_image = TexPlay.create_image($window, $window.width / $window.sprite_scale,
                                               $window.height / $window.sprite_scale, color: BACKGROUND_COLOR)

      @background_image.refresh_cache

      @background_image.rect 0, @background_image.height - TIME_BAR_THICKNESS,
                             @background_image.width, @background_image.height,
                             color: :black, fill: true

      @time_font = Font["pixelated.ttf", 24]

      Command::Y_POSITIONS.each_value do |y|
        Fire.create(x: $window.retro_width / 2, y: y)
        Fire.create(x: $window.retro_width / 2, y: y + 3.5)
      end

      on_input(:escape) { pop_game_state }
      minutes, seconds = @track[:duration].split(':').map {|t| t.to_i }

      @track_duration = ((minutes * 60) + seconds) * 1000.0
      @game_duration = 0

      log.info { "Playing track '#{track[:name]}' from '#{@track[:file]}' for #{@track[:duration]} (#{@track_duration}ms)" }

      @song = Song[@track[:file]]
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

      # Time bar.
      remaining_time = @track_duration - @game_duration
      width = [$window.retro_width * (remaining_time / @track_duration), 0].max
      $window.pixel.draw_rot $window.retro_width / 2, $window.retro_height, ZOrder::SCORE, 0, 0.5, 1, width, TIME_BAR_THICKNESS

      time = "%d:%02d" % (remaining_time / 1000.0).divmod(60)
      $window.scale(1.0 / $window.sprite_scale) do
        @time_font.draw_rel time, $window.width / 2, $window.height, ZOrder::GUI, 0.5, 1, 1, 1, TIME_COLOR
      end
    end

    def update
      remaining_time = @track_duration - @game_duration
      if @song.playing? and remaining_time > 0
        @game_duration = [@game_duration + frame_time, @track_duration].min
        super
      else
        push_game_state GameOver
      end
    end
  end
end