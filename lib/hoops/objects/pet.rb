module Hoops
  class Pet < PhysicsObject
    WALK_ANIMATION_FRAMES = 0..3 # Walking on the hoop or away.
    WALK_ANIMATION_DELAY = 125

    DANCE_ANIMATION_FRAMES = 4..7 # Dancing next to the player.
    DANCE_ANIMATION_DELAY = 250

    def initialize(command, animations, options = {})
      options = {
          elasticity: 0.4,
          state: :walking,
      }.merge! options

      super options

      @command = command
      @command.contents = self
      self.x = @command.x
      self.y = @command.y
      self.z = @command.z + @command.height
      self.factor_x = -1 if x > 0

      @animations = Animation.new(file: animations)
      self.state = options[:state]
    end

    def update
      if @command
        self.x = @command.x
        self.z = @command.z + @command.height
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
      @command = nil
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