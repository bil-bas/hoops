module Chingu
  class GameState
    include Hoops::Log

    SETTINGS_CONFIG_FILE = 'settings.yml' # The general settings file.
    GLOW_WIDTH = 64
    MAX_FRAME_TIME = 100 # Milliseconds cap on frame calculations.

    # Settings object, containing general settings from config.
    def settings; @@settings; end

    alias_method :original_initialize, :initialize
    public
    def initialize(options = {})
      @@settings ||= Hoops::Settings.new(SETTINGS_CONFIG_FILE)
      on_input(:f12) { pry } if respond_to? :pry
      original_initialize(options)

      make_glow unless defined? @@glow
    end

    public
    # Milliseconds since the last frame, but capped, so we don't break physics.
    def frame_time
      [$window.dt, MAX_FRAME_TIME].min
    end

    public
    # Find an object, via its network ID.
    def object_by_id(id)
      game_objects.object_by_id(id)
    end

    public
    def glow; @@glow; end

    public
    def make_glow
      @@glow = TexPlay.create_image($window, GLOW_WIDTH, GLOW_WIDTH, color: :alpha)
      @@glow.refresh_cache
      @@glow.clear color: :alpha

      center = @@glow.width / 2.0
      radius =  @@glow.width / 2.0

      @@glow.circle center, center, radius, :filled => true,
        :color_control => lambda {|source, dest, x, y|
          # Glow starts at the edge of the pixel (well, its radius, since glow is circular, not rectangular)
          distance = distance(center, center, x, y)
          dest[3] = (1 - (distance / radius)) ** 2
          dest
        }
    end
  end
end