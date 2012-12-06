require_relative "base_object"

module Hoops
  class Word < BaseObject
    def initialize(name, options = {})
      options = {

      }.merge! options
      super options

      @@images ||= {}
      @@images[name] ||= Image["word_#{name}.png"]
      @image = @@images[name]

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