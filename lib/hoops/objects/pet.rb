require_relative "physics_object"
require_relative "pixel"

module Hoops
  class Pet < PhysicsObject
    WALK_ANIMATION_FRAMES = 0..3 # Walking on the hoop or away.
    WALK_ANIMATION_DELAY = 125

    DANCE_ANIMATION_FRAMES = 4..7 # Dancing next to the player.
    DANCE_ANIMATION_DELAY = 250
    VARIATIONS = [:cat_1, :cat_2, :monkey_1]

    def initialize(hoop, options = {})
      options = {
          elasticity: 0.4,
          state: :walking,
      }.merge! options

      @type = VARIATIONS.sample

      super options

      @hoop = hoop
      @hoop.contents = self
      self.x = @hoop.x
      self.y = @hoop.y
      self.z = @hoop.z + @hoop.height
      self.factor_x = -1 if x > 0

      @animations = Animation.new(file: "pet_#{@type}_16x16.png")
      self.state = options[:state]
    end

    def update
      if @hoop
        self.x = @hoop.x
        self.z = @hoop.z + @hoop.height
      else
        super
      end

      if @player
        @player.add_score(parent.frame_time / 10.0)
      end

      self.image = @current_animation.next
    end

    def command_destroyed
      destroy
    end

    def state=(state)
      case state
        when :walking
          @current_animation = @animations[WALK_ANIMATION_FRAMES]
          @current_animation.delay = WALK_ANIMATION_DELAY
        when :dancing
          @current_animation = @animations[DANCE_ANIMATION_FRAMES]
          @current_animation.delay = DANCE_ANIMATION_DELAY
        else
          raise "Unknown pet mode: #{state.inspect}"
      end

      @state = state

      self.image = @current_animation[0]
    end

    def command_performed(player)
      @hoop = nil
      explode(Pixel)
      self.state = :dancing
      @player = player
      player.pet = self
    end

    def dismiss
      @player = nil
      explode(Pixel)
      destroy
    end
  end
end