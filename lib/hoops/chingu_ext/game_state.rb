module Chingu
  class GameState
    include Hoops::Log

    SETTINGS_CONFIG_FILE = 'settings.yml' # The general settings file.

    MAX_FRAME_TIME = 100 # Milliseconds cap on frame calculations.

    # Settings object, containing general settings from config.
    def settings; @@settings; end

    alias_method :original_initialize, :initialize
    public
    def initialize(options = {})
      @@settings ||= Hoops::Settings.new(SETTINGS_CONFIG_FILE)
      on_input(:f12) { pry } if respond_to? :pry
      original_initialize(options)
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
  end
end