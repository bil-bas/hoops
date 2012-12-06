module Hoops
  class Direction < GameObject
    trait :timer

    attr_reader :name

    PERFECT_HIT_FLASH_DURATION = 500
    HIT_FLASH_DURATION = 250
    MISS_FLASH_DURATION = 250
    MISS_MUTE_DURATION = 500

    def initialize(player, name, options = {})
      @player, @name = player, name

      @default_color = Hoop::COLORS[name].dup
      @default_color.red /= 4
      @default_color.blue /= 4
      @default_color.green /= 4

      @miss_color = Hoop::COLORS[name].dup
      @miss_color.red /= 2
      @miss_color.blue /= 2
      @miss_color.green /= 2

      options = {
          image: Image["direction_6x6.png"],
          rotation_center: :center_center,
          color: @default_color,
          zorder: ZOrder::TILES,
      }.merge! options

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
      flash(Hoop::COLORS[name].dup, HIT_FLASH_DURATION)
      @player.increment_multiplier
      #@hit_sample.play(0.5)
    end

    def perfect_hit
      flash(Hoop::COLORS[name].dup, PERFECT_HIT_FLASH_DURATION)
      @player.increment_multiplier
      #@hit_sample.play(0.8)
    end

    def miss
      flash(@miss_color, MISS_FLASH_DURATION)
      parent.mute_song(MISS_MUTE_DURATION)
      @player.reset_multiplier
      @miss_sample.play
    end

    def flash(color, duration)
      self.color = color
      after(duration) { self.color = @default_color }
    end

    def draw
      if color.red > 100 or color.green > 100 or color.blue > 100
        glow_color = color.dup
        glow_size = 0.7
        glow_color.alpha = case @name
                             when :up    then 255 # Red
                             when :down  then 75 # Cyan
                             when :left  then 75 # Yellow
                             when :right then 150 # Magenta
                           end

        parent.glow.draw_rot x, y, zorder, 0, 0.5, 0.5, glow_size, glow_size, glow_color, :additive
      end

      super
    end
  end
end