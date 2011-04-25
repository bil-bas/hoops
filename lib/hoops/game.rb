# Standard libs
require 'forwardable'
require 'yaml'
require 'fileutils'
require 'logger'

# Gems
require 'chingu'
require 'texplay'
require 'fidgit'

SCHEMA_FILE = File.join(EXTRACT_PATH, 'lib', 'hoops', 'schema.yml')


begin
  # If this isn't the exe, allow dropping into a pry session.
  unless defined? Ocra
    require 'pry'
    require 'win32console'
  end
rescue LoadError
end

include Gosu
include Chingu

RequireAll.require_all File.dirname(__FILE__)

Gosu::Sample.volume = 0.5

Fidgit::Element.schema.merge_elements! YAML.load(File.read(SCHEMA_FILE))

module Hoops
module ZOrder
  BACKGROUND = -Float::INFINITY
  TILES = -3
  SHADOWS = -2
  BACK_GLOW = -1
  PLAYER = 1
  FOREGROUND = 9999
  GUI = 10000
end

class Game < Window
  include Log

  SIZE = [640, 480]

  TITLE = "=== An indeterminate number of hoops ==="
  attr_reader :pixel, :sprite_scale

  def retro_width; width / @sprite_scale; end
  def retro_height; height / @sprite_scale; end

  # To change
  def setup
    media_dir = File.expand_path(File.join(EXTRACT_PATH, 'media'))
    Image.autoload_dirs.unshift File.join(media_dir, 'images')
    Sample.autoload_dirs.unshift File.join(media_dir, 'sounds')
    Song.autoload_dirs.unshift File.join(media_dir, 'music')
    Font.autoload_dirs.unshift File.join(media_dir, 'fonts')

    retrofy
    @sprite_scale = 8

    @used_time = 0
    @last_time = milliseconds
    @potential_fps = 0

    @pixel = TexPlay.create_image($window, 1, 1, color: Color.rgb(255, 255, 255))

    push_game_state Menu
  end


  def draw
    draw_started = milliseconds

    # Draw sprites at the retrofied scale.
    scale(@sprite_scale) do
      super
    end

    @used_time += milliseconds - draw_started
  end

  def update
    update_started = milliseconds

    super

    self.caption = "#{TITLE} [FPS: #{fps} (#{@potential_fps})]"

    @used_time += milliseconds - update_started

    recalculate_cpu_load
  end

  def recalculate_cpu_load
    if (milliseconds - @last_time) >= 1000
      @potential_fps = (fps / [(@used_time.to_f / (milliseconds - @last_time)), 0.0001].max).floor
      @used_time = 0
      @last_time = milliseconds
    end
  end

  def self.run
    new(*SIZE, false).show
  end
end

end