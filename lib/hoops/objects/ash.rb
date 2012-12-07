require_relative "physics_object"

module Hoops
  class Ash < PhysicsObject
    def initialize(options = {})
      options = {
          image: $window.pixel,
          elasticity: 0,
          velocity_z: rand * 0.5,
      }.merge! options

      # Ash is always black. Just live with it!
      super options.merge(color: Color::BLACK)
    end

    def update
      if @z <= 0
        destroy
      else
        super
      end
    end
  end
end