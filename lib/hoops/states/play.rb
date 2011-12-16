require_folder "objects", %w[cat direction fire player]


module Hoops
  class Play < GameState
    trait :timer

    BACKGROUND_COLOR = Color.rgb(26, 114, 179)
    SONG_VOLUME_MUTED = 0.20 # 1/5 fof normal volume when muted

    TIME_BAR_THICKNESS = 3
    TIME_COLOR = Color.rgb(0, 80, 140)

    PLAYER_Y = 24

    def initialize(settings1, settings2, track, max_length)
      super()

      @track = track

      middle = (($window.retro_width - 1) / 2.0)

      @parameters = [settings1, settings2, track, max_length]

      @player1 = Player.create(0, settings1, x: middle - 8, y: PLAYER_Y) unless settings1.nil?
      @player2 = Player.create(1, settings2, x: middle + 8, y: PLAYER_Y)  unless settings2.nil?

      @background_image = TexPlay.create_image($window, $window.width / $window.sprite_scale,
                                               $window.height / $window.sprite_scale, color: BACKGROUND_COLOR)

      @background_image.refresh_cache

      @background_image.rect 0, @background_image.height - TIME_BAR_THICKNESS,
                             @background_image.width, @background_image.height,
                             color: :black, fill: true

      @time_font = Font["pixelated.ttf", 24]

      Command::Y_POSITIONS.each_value do |y|
        Fire.create(x: $window.retro_width / 2, y: y) if @player1
        Fire.create(x: $window.retro_width / 2, y: y + 3.5) if @player2
      end

      on_input(:escape) { pop_game_state }

      @track_duration_ms = [@track.duration, max_length].min * 1000.0
      @game_duration = 0

      log.info { "Playing track '#{@track.name}' from '#{@track.file}' for #{@track.duration_string}" }

      @volume_full = @track.volume
      @volume_muted = @volume_full * SONG_VOLUME_MUTED

      @song = Song[@track.file]
      @song.volume = @volume_full
      @song.pause
    end

    def restart
      switch_game_state Play.new(*@parameters)
    end

    def setup
      @song.play
    end

    def finalize
      @song.stop
    end

    def mute_song(duration)
      @song.volume = @volume_muted
      after(duration, name: :unmute) { @song.volume = @volume_full }
    end

    def draw
      super

      @background_image.draw(0, 0, ZOrder::BACKGROUND)

      # Time bar.
      remaining_time = @track_duration_ms - @game_duration
      width = [$window.retro_width * (remaining_time / @track_duration_ms), 0].max
      $window.pixel.draw_rot $window.retro_width / 2, $window.retro_height, ZOrder::SCORE, 0, 0.5, 1, width, TIME_BAR_THICKNESS

      time = "%d:%02d" % (remaining_time / 1000.0).divmod(60)
      $window.scale(1.0 / $window.sprite_scale) do
        @time_font.draw_rel time, $window.width / 2, $window.height, ZOrder::GUI, 0.5, 1, 1, 1, TIME_COLOR
      end
    end

    def update
      remaining_time = @track_duration_ms - @game_duration
      if @song.playing? and remaining_time > 0
        @game_duration = [@game_duration + frame_time, @track_duration_ms].min
        super
      else
        game_over
      end
    end

    def game_over
      if @player1 and @player2
        if @player1.score > @player2.score
          @player1.win
          @player2.lose
        elsif @player2.score > @player1.score
          @player1.lose
          @player2.win
        else
          @player1.win
          @player2.win
        end
      elsif @player1
        @player1.win
      elsif @player2
        @player2.win
      end

      push_game_state GameOver
    end
  end
end