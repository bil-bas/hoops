# Standard libs
require 'forwardable'
require 'yaml'
require 'fileutils'
require 'logger'

begin
  require 'bundler/setup' unless defined?(OSX_EXECUTABLE) or ENV['OCRA_EXECUTABLE']

rescue LoadError
  $stderr.puts "Bundler gem not installed. To install:\n  gem install bundler"
  exit
rescue Exception
  $stderr.puts "Gem dependencies not met. To install:\n  bundle install"
  exit
end

# Gems
require 'ogginfo'
require 'chingu'
require 'texplay'
require 'fidgit'

SCHEMA_FILE = File.join(EXTRACT_PATH, 'lib', 'hoops', 'schema.yml')

include Gosu
include Chingu

def require_folder(path, files)
  files.each do |file|
    if path.empty?
      require_relative file
    else
      require_relative File.join(path, file)
    end
  end
end

require_relative "log"

require_folder "gosu_ext", %w[color]
require_folder "texplay_ext", %w[image]
require_folder "chingu_ext", %w[animation game_object_list game_state sample song]
require_folder "fidgit_ext", %w[element]

require_folder "ogginfo_ext", %w[ogg]

require_folder "", %w[settings tracklist version]
require_folder "states", %w[add_track difficulty game_over menu options_playlist play]

Gosu::Sample.volume = 0.5

Fidgit::Element.schema.merge_elements! YAML.load(File.read(SCHEMA_FILE))

module Hoops
module ZOrder
  BACKGROUND = -Float::INFINITY
  TILES = -4
  SHADOWS = -3
  SCORE = -2
  BACK_GLOW = -1
  # Objects are 0+
  GUI = 10000
end

class Game < Window
  include Log

  SIZE = [768, 480]

  TITLE = "=== An indeterminate number of HOOPS v#{VERSION} ==="
  attr_reader :pixel, :sprite_scale

  def retro_width; width / @sprite_scale; end
  def retro_height; height / @sprite_scale; end

  # To change
  def setup
    %w[Gosu Chingu Fidgit TexPlay].each do |gem|
      log.info { "Using #{gem} gem (#{Kernel.const_get(gem)::VERSION})" }
    end

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

    update_caption

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

  def update_caption
    self.caption = "#{TITLE} [FPS: #{fps} (#{@potential_fps})]"
  end

  def update
    update_started = milliseconds

    super

    @used_time += milliseconds - update_started

    recalculate_cpu_load
  end

  def recalculate_cpu_load
    if (milliseconds - @last_time) >= 1000
      @potential_fps = (fps / [(@used_time.to_f / (milliseconds - @last_time)), 0.0001].max).floor
      @used_time = 0
      @last_time = milliseconds

      update_caption
    end
  end

  def self.run
    new(*SIZE, false).show
  end
end

end