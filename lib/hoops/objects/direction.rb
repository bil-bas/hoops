module Hoops
  class Direction < GameObject
    trait :timer

    attr_reader :name

    PERFECT_HIT_FLASH_DURATION = 500
    HIT_FLASH_DURATION = 250
    MISS_FLASH_DURATION = 250
    MISS_MUTE_DURATION = 500

    def initialize(player, name, options = {})
      options = {
          image: Image["direction_6x6.png"],
          color: Color.rgb(0, 0, 0),
          zorder: ZOrder::TILES,
      }.merge! options

      @player, @name = player, name

      super options

      case @name
        when :up
          self.angle = 0
          blip = 4
        when :down
          self.angle = 180
          blip = 3
        when :left
          self.angle = 270
          blip = 2
        when :right
          self.angle = 90
          blip = 1
      end
      @hit_sample = Sample["blip#{blip}.ogg"]
      @miss_sample = Sample["miss.ogg"]
    end

    def hit
      flash(Command::COLORS[name].dup, HIT_FLASH_DURATION)
      @player.increment_multiplier
      @hit_sample.play(0.5)
    end

    def perfect_hit
      flash(Command::COLORS[name].dup, PERFECT_HIT_FLASH_DURATION)
      @player.increment_multiplier
      @hit_sample.play(0.8)
    end

    def miss
      color = Command::COLORS[name].dup
      color.alpha /= 3
      flash(color, MISS_FLASH_DURATION)
      parent.mute_song(MISS_MUTE_DURATION)
      @player.reset_multiplier
      @miss_sample.play
    end

    def flash(color, duration)
      self.color = color
      after(duration) { self.color = Color.rgb(0, 0, 0) }
    end
  end
end