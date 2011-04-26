module Hoops
  class Command < PhysicsObject
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

    attr_reader :direction, :contents

    def contents=(object); @contents = object; end

    def initialize(options = {})
      options = {
          z: 5,
          velocity_z: 0.7,
          elasticity: 0.85
      }.merge! options

      @contents = nil
      @direction = options[:direction]

      super options

      self.y = Y_POSITIONS[@direction]

      @@animation ||= Animation.new(file: ANIMATION_FILE, delay: 250)
      @animation = @@animation.dup

      self.image = @animation.frames[0]
      self.color = COLORS[@direction]
    end

    def update
      super
      self.image = @animation.next
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