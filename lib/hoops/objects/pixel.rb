require_relative "base_object"

module Hoops
  class Pixel < BaseObject
    def initialize(options = {})
      options = {
         image: $window.pixel,
      }.merge! options

      super options

      @upward_velocity = 0.3 + rand(0.15)
    end

    def update
      @z += @upward_velocity
      if @z >= 50
        destroy
      else
        self.alpha = (255 - @z * 5).round
      end
    end
  end
end