module Hoops
  class Pixel < BaseObject
    def initialize(options = {})
      @@pixel ||= TexPlay.create_image($window, 1, 1, color: :white)
      super options
      self.image = @@pixel
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