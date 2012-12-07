require_relative "base_object"
require_relative "../incoming_list"

module Hoops
  class Player < BaseObject
    trait :timer

    KEYS_CONFIG_FILE = 'keys.yml'
    SCORE_INDENT = 10
    PET_OFFSET = 15

    FALLEN_DURATION = 500 # ms

    module AnimationFrame
      WIN = 12
      LOSE = 13
      FALL = 14
    end

    module Dance
      module Multiplier
        INITIAL = 1
        MAX = 20

        SLOW = 1
        NORMAL = 2..9
        FAST = 10..19
        ULTRA = 20
      end

      module Set
        SLOW = 0
        NORMAL = 1
        FAST = 2
        ULTRA = 2 # TODO: Make a full speed dance.
      end
    end

    class << self
      def keys_config
        @keys_config ||= Settings.new(KEYS_CONFIG_FILE)
      end
    end

    attr_reader :number, :difficulty_settings, :score
    def disable_hoops; @incoming.disable end
    def fallen?; @fallen end

    def initialize(number, song_file, difficulty_settings, options = {})
      options = {
          factor: 1.25,
      }.merge! options

      super options

      @number, @difficulty_settings = number, difficulty_settings

      log.debug { "Playing with difficulty: #{@difficulty_settings}" }

      @animations = Animation.new(file: "player#{@number + 1}_16x16.png", delay: 250)
      @animation_sets = [@animations[0..3], @animations[4..7], @animations[8..11]]

      @incoming = IncomingList.create(self, song_file, difficulty_settings)

      @score = 0
      @multiplier = Dance::Multiplier::INITIAL
      update_dance_set
      self.image = @animations[0]

      @score_font = Font["pixelated.ttf", 40]
      @multiplier_font = Font["pixelated.ttf", 80]

      [:left, :right, :up, :down].each do |direction|
        on_input(self.class.keys_config[:players, @number + 1, direction], direction)
      end

      @hoops_disabled = false

      @score_x = (@number == 1) ? $window.width - SCORE_INDENT : SCORE_INDENT
      @score_align = (@number == 1) ? 1 : 0

      @fallen = false
    end

    def update
      super

      self.image = @current_animation.next unless fallen?
    end

    def win
      self.image = @animations[AnimationFrame::WIN]
    end

    def lose
      if @number == 0
        @x -= 6
      elsif @number == 1
        @x += 6
      end

      self.image = @animations[AnimationFrame::LOSE]
    end

    def reset_multiplier
      if @pet
        @pet.dismiss
        @pet = nil
      end

      @multiplier = 1

      update_dance_set

      fall_over
    end

    def fall_over
      self.image = @animations[AnimationFrame::FALL]
      @fallen = true
      after(FALLEN_DURATION, name: :get_up) { get_up }
    end

    def get_up
      stop_timer :get_up
      @fallen = false
    end

    def increment_multiplier
      get_up if fallen?

      @multiplier += 1 unless @multiplier == Dance::Multiplier::MAX

      update_dance_set
    end

    def update_dance_set
      new_set = case @multiplier
                  when Dance::Multiplier::SLOW
                    Dance::Set::SLOW
                  when Dance::Multiplier::NORMAL
                    Dance::Set::NORMAL
                  when Dance::Multiplier::FAST
                    Dance::Set::FAST
                  when Dance::Multiplier::ULTRA
                    Dance::Set::ULTRA
                  else
                    raise "Bad dance multiplier"
                end

      @current_animation = @animation_sets[new_set]
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