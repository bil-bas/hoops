require_relative "physics_object"

# Actually a hoop :)

module Hoops
  class Hoop < PhysicsObject
    DIRECTIONS = [:up, :down, :left, :right]
    Y_POSITIONS = {
        up: 31,
        down: 38,
        left: 45,
        right: 52,
    }

    ANIMATION_FILE = "rolling_hoop_9x9.png"

    COLORS = {
        up: Color.rgb(255, 0, 0), # Red
        down: Color.rgb(0, 255, 255), # Cyan
        left: Color.rgb(255, 255, 0), # Yellow
        right: Color.rgb(255, 0, 255), # Magenta
    }

    PERSISTENT_FRAMES = 25

    attr_reader :direction, :contents

    def contents=(object); @contents = object; end

    def initialize(options = {})
      options = {
          z: 5,
          velocity_z: 0.7,
          elasticity: 0.9
      }.merge! options

      @contents = nil
      @direction = options[:direction]

      super options

      self.y = Y_POSITIONS[@direction]

      @@animation ||= Animation.new(file: ANIMATION_FILE, delay: 250)
      @animation = @@animation.dup

      self.image = @animation.frames[0]
      self.color = COLORS[@direction]
      @positions = []
    end

    def update
      super
      self.image = @animation.next
    end

    def draw
      color = self.color.dup

      # Draw a blurry glow behind the moving hoops.
      @positions.each.with_index do |(x, y, z), i|
        next if i == 0

        # Different colours need different alphas to appear equally bright.
        color.alpha = case direction
                        when :up
                          15 - i / 2
                        when :down, :left
                          6 - i / 5
                        when :right
                          10 - i / 3
                      end

        @image.draw_rot x, y - z, y, 0, 0.5, 1.0, 1, 1, color, :add
      end

      # Store the last number of frames.
      @positions.unshift [x, y, z]
      # Trim excess frames.
      @positions.pop while @positions.size > PERSISTENT_FRAMES

      super
    end

    def performed(player)
      @contents.command_performed(player) if @contents
      @contents = nil
    end

    def destroy
      @contents.command_destroyed if @contents
      super
    end
  end
end