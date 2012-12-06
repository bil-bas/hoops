require_relative "base_object"

module Hoops
  class SpinningHoop < BaseObject
    def initialize(options = {})
      options = {
          rotation_center: :bottom_center,
      }.merge! options

      @animation = Animation.new(file: "spinning_hoop_9x9.png", delay: 500, bounce: true)
      super(options)
      self.image = @animation.next
    end

    def update
      self.image = @animation.frames[3 - Math::sin(milliseconds / 400.0).abs * 3.0]
    end
  end
end