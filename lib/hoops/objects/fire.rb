require_relative "base_object"

module Hoops
  class Fire < BaseObject
    def initialize(options = {})
      @current_animation = Animation.new(file: "fire_8x8.png", delay: 250)

      options = {
          factor: 0.7,
          rotation_center: :center_bottom,
          image: @current_animation[0],
          casts_shadow: false,
      }.merge! options

      super options
    end

    def update
      self.image = @current_animation.next
    end
  end
end