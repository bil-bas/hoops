require_folder "objects", %w[ash cat word command pixel]

module Hoops
  # List of incoming creatures.
  class IncomingList < GameObject
    include Hoops::Log

    trait :timer

    RAIL_COLOR = Color.rgba(0, 0, 0, 50)

    HIT_RANGE = 10
    PERFECT_RANGE = 2

    HIT_SCORE = 1000

    SPEED = 0.02
    BASE_INTERVAL = 500

    PERFECT_MULTIPLIER = 2

    PET_CLASSES = [Cat]
    PET_CHANCE = 0.1

    def disable; stop_timer :create_hoops end
    def direction_valid?(direction); @valid_directions.include? direction end

    def initialize(player, song_name, options = {})
      super(options)

      # Everything that happens is based on a random number generator seeded based on the name of the track played.
      song_name = File.basename song_name, File.extname(song_name)
      @randomizer = Random.new song_name.hash

      @player, @difficulty_settings = player, player.difficulty_settings

      @list = []
      @direction_icons = {}

      @valid_directions = Command::DIRECTIONS.dup
      @valid_directions.delete :up if @difficulty_settings[:num_directions] < 4

      Command::Y_POSITIONS.each_pair do |direction, direction_y|
        next unless direction_valid? direction

        @direction_icons[direction] = Direction.create(@player, direction, x: @player.x, y: direction_y)
      end

      if @player.number == 1
        @speed = -SPEED
        @create_x = $window.retro_width - 1 + 5
      else
        @speed = SPEED
        @create_x = -5
      end

      @x = @player.x
      @hit_range = (@player.x - HIT_RANGE / 2)..(@player.x + HIT_RANGE / 2)
      @perfect_range = (@player.x - PERFECT_RANGE / 2)..(@player.x + PERFECT_RANGE / 2)

      @num_since_gap = 0

      every(BASE_INTERVAL, name: :create_hoops ) { new_command }
    end


    public
    def update
      # Move all objects over.
      @list.each {|c| c.x += @speed * parent.frame_time }

      while @list.first and
            ((@speed > 0 and @list.first.x > @hit_range.max) or
            (@speed < 0 and @list.first.x < @hit_range.min))
        command = @list.first
        command.explode(Ash)
        command.contents.explode(Ash) if @list.first.contents
        command.destroy
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
      return unless direction_valid? direction

      command = @list[0..3].find {|c| c.direction == direction }
      if command
        if @hit_range.include? command.x
          if @perfect_range.include? command.x
            @direction_icons[direction].perfect_hit
            @player.add_score(HIT_SCORE * @difficulty_settings[:multiplier] * PERFECT_MULTIPLIER)
            Word.create(:perfect, x: command.x, y: command.y, z: command.z + command.height / 2)
            command.explode(Pixel) # Double explosion for a perfect.
          else
            @direction_icons[direction].hit
            @player.add_score(HIT_SCORE * @difficulty_settings[:multiplier])
          end

          @list.delete command
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
    # Layout of hoops and gaps based on difficulty.
    # Easy    O.O.O.O.O.O.O.O.
    # Normal  O.O.O.O.O.O.O.O.
    # Hard    OOO.OOO.OOO.OOO.
    # Awesome OOOOOOO.OOOOOOO.
    def new_command
      # Generate all random numbers, even if they may not be used. This keeps the generator state constant.
      direction = Command::DIRECTIONS[@randomizer.rand Command::DIRECTIONS.size]
      valid_direction = @valid_directions.include? direction

      pet_type = PET_CLASSES[@randomizer.rand PET_CLASSES.size]
      pet_appears = @randomizer.rand < PET_CHANCE

      gap_needed = @num_since_gap == @difficulty_settings[:bar_length]

      if gap_needed
        @num_since_gap = 0
      else
        if valid_direction
          command = Command.create x: @create_x, direction: direction, factor_x: @create_x < 0 ? -1 : 1
          pet_type.create command if pet_appears
          @list << command
        end

        @num_since_gap += 1
      end
    end
  end
end