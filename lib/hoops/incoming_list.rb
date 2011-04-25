module Hoops
  # List of incoming creatures.
  class IncomingList < GameObject
    trait :timer

    RAIL_COLOR = Color.rgba(0, 0, 0, 50)

    HIT_RANGE = 10
    PERFECT_RANGE = 2

    HIT_SCORE = 100

    PERFECT_MULTIPLIER = 2

    PET_CHANCE = 10
    PET_CLASSES = [Cat]

    DIFFICULTY_NAMES = [:easy, :normal, :hard]
    DIFFICULTY_TIMINGS = {
        easy: 1500,
        normal: 1000,
        hard: 600,
    }

    SPEEDS = {
        easy: 0.015,
        normal: 0.02,
        hard: 0.03,
    }

    SCORE_MULTIPLIER = {
        easy: 0.5,
        normal: 1,
        hard: 2,
    }

    def initialize(player, difficulty, options = {})
      super(options)

      @player = player

      @list = []
      @direction_icons = {}
      @difficulty_multiplier = SCORE_MULTIPLIER[difficulty]

      Command::Y_POSITIONS.each_pair do |direction, direction_y|
        @direction_icons[direction] = Direction.create(@player, direction, x: @player.x, y: direction_y)
      end

      @speed = SPEEDS[difficulty]
      if @player.number == 1
        @speed = -@speed
        @create_x = 84
      else
        @create_x = -5
      end

      @x = @player.x
      @hit_range = (@player.x - HIT_RANGE / 2)..(@player.x + HIT_RANGE / 2)
      @perfect_range = (@player.x - PERFECT_RANGE / 2)..(@player.x + PERFECT_RANGE / 2)

      every(DIFFICULTY_TIMINGS[difficulty]) { new_command }
    end


    public
    def update
      # Move all objects over.
      @list.each {|c| c.x += @speed * parent.frame_time }

      # Destroy any that get too far...
      if @list.first and ((@speed > 0 and @list.first.x > @hit_range.max) or
                          (@speed < 0 and @list.first.x < @hit_range.min))
        @list.first.explode(Ash)
        @list.first.contents.explode(Ash) if @list.first.contents
        @list.first.destroy
        @list.shift
        @player.reset_multiplier
      end
    end

    def draw
      $window.pixel.draw @hit_range.min, 0, ZOrder::TILES,
                         HIT_RANGE, $window.retro_height, RAIL_COLOR
    end

    public
    def command_performed(direction)
      command = @list[0..3].find {|c| c.direction == direction }
      if command
        if @hit_range.include? command.x
          if @perfect_range.include? command.x
            @direction_icons[direction].perfect_hit
            @player.add_score(HIT_SCORE * @difficulty_multiplier * PERFECT_MULTIPLIER)
            command.explode(Pixel) # Double explosion for a perfect.
          else
            @direction_icons[direction].hit
            @player.add_score(HIT_SCORE * @difficulty_multiplier)
          end

          @list.shift
          command.explode(Pixel)
          command.performed(@player)
          command.destroy
        else
          @direction_icons[direction].miss # Doesn't map to any commands on rails.
        end
      else
        @direction_icons[direction].miss # No correct commands possible.
      end
    end

    public
    def destroy
      @list.each(&:destroy)
      super
    end

    protected
    def new_command
      command = Command.create(x: @create_x, direction: Command::DIRECTIONS.sample, factor_x: @create_x < 0 ? -1 : 1)

      if rand(100) < PET_CHANCE
        PET_CLASSES.sample.create(command)
      end

      @list << command
    end
  end
end