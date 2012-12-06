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

    PERFECT_MULTIPLIER = 2

    PET_CLASSES = [Cat]

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
      @valid_directions.delete @difficulty_settings[:disabled_direction]

      Command::Y_POSITIONS.each_pair do |direction, direction_y|
        next unless direction_valid? direction

        @direction_icons[direction] = Direction.create(@player, direction, x: @player.x, y: direction_y)
      end

      if @player.number == 1
        @speed = -@difficulty_settings[:speed]
        @create_x = $window.retro_width - 1 + 5
      else
        @speed = @difficulty_settings[:speed]
        @create_x = -5
      end

      @x = @player.x
      @hit_range = (@player.x - HIT_RANGE / 2)..(@player.x + HIT_RANGE / 2)
      @perfect_range = (@player.x - PERFECT_RANGE / 2)..(@player.x + PERFECT_RANGE / 2)

      every(@difficulty_settings[:interval]) { new_command }
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
    def new_command
      return if @randomizer.rand < @difficulty_settings[:gap_chance]

      direction = @valid_directions[@randomizer.rand @valid_directions.size]
      command = Command.create(x: @create_x, direction: direction, factor_x: @create_x < 0 ? -1 : 1)

      if @randomizer.rand < @difficulty_settings[:pet_chance]
        PET_CLASSES[@randomizer.rand PET_CLASSES.size].create(command)
      end

      @list << command

      if @randomizer.rand < @difficulty_settings[:double_chance]
        directions = @valid_directions - [command.direction]
        direction = directions[@randomizer.rand directions.size]
        @list << Command.create(x: @create_x, direction: direction, factor_x: @create_x < 0 ? -1 : 1)
      end
    end
  end
end