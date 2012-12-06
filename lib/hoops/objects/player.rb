require_relative "base_object"
require_relative "../incoming_list"

module Hoops
  class Player < BaseObject
    MAX_MULTIPLIER = 20
    KEYS_CONFIG_FILE = 'keys.yml'
    SCORE_INDENT = 10
    PET_OFFSET = 15

    attr_reader :number, :difficulty_settings, :score

    def initialize(number, song_file, difficulty_settings, options = {})
      options = {
          factor: 1.25,
      }.merge! options

      super options

      @number, @difficulty_settings = number, difficulty_settings

      log.debug { "Playing with difficulty: #{@difficulty_settings}" }

      @animations = Animation.new(file: "player#{@number + 1}_16x16.png", delay: 250)
      @animation_sets = [@animations[0..3], @animations[4..7], @animations[8..11]]
      @current_animation = @animation_sets[0]
      self.image = @animations[0]

      @@keys_config ||= Settings.new(KEYS_CONFIG_FILE)

      @incoming = IncomingList.create(self, song_file, difficulty_settings)

      @score = 0
      @multiplier = 1
      @score_font = Font["pixelated.ttf", 40]
      @multiplier_font = Font["pixelated.ttf", 80]

      [:left, :right, :up, :down].each do |direction|
        on_input(@@keys_config[:players, @number + 1, direction], direction)
      end

      @score_x = (@number == 1) ? $window.width - SCORE_INDENT : SCORE_INDENT
      @score_align = (@number == 1) ? 1 : 0
    end

    def update
      super
      self.image = @current_animation.next
    end

    def win
      self.image = @animations[12]
    end

    def lose
      if @number == 0
        @x -= 6
      elsif @number == 1
        @x += 6
      end

      self.image = @animations[13]
    end

    def reset_multiplier
      if @pet
        @pet.dismiss
        @pet = nil
      end

      if @multiplier > 1
        @current_animation = @animation_sets[0]
      end

      @multiplier = 1
    end

    def increment_multiplier
      case @multiplier
        when 1
          @current_animation = @animation_sets[1]
        when 19
          @current_animation = @animation_sets[2]
      end

      @multiplier += 1 unless @multiplier == MAX_MULTIPLIER
    end

    def add_score(score)
      @score += (score * @multiplier).to_i
    end

    def draw
      $window.scale(1.0 / $window.sprite_scale) do
        @score_font.draw_rel(@score.to_s.rjust(9, '0'), @score_x, 4, ZOrder::SCORE, @score_align, 0)
        @multiplier_font.draw_rel("x #{@multiplier.to_s.rjust(2, '0')}", @score_x, 26, ZOrder::SCORE, @score_align, 0)
      end

      super
    end

    def up
      @incoming.command_performed(:up)
    end

    def down
      @incoming.command_performed(:down)
    end

    def right
      @incoming.command_performed(:right)
    end

    def left
      @incoming.command_performed(:left)
    end

    def pet=(pet)
      @pet.dismiss if @pet

      @pet = pet
      @pet.x = x + ((@number == 1) ? +PET_OFFSET : -PET_OFFSET)
      @pet.y = y
      @pet.z = 50
    end
  end
end