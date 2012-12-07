require_relative "base_object"

module Hoops
  class Word < BaseObject
    class << self
      def image(name)
        @images ||= Hash.new {|h, k| h[k] = Image["word_#{name}.png"] }
        @images[name]
      end
    end

    def initialize(name, options = {})
      options = {

      }.merge! options
      super options

      @image = self.class.image name

      @upward_velocity = 0.2
    end

    def update
      @z += @upward_velocity
      if @z >= 12
        destroy
      else
        self.alpha = (255 - @z * 20).round
      end
    end
  end
end