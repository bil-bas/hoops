module Hoops
  class Ash < PhysicsObject
    def initialize(options = {})
      @@pixel ||= TexPlay.create_image($window, 1, 1, color: :black)

      options = {
          image: @@pixel,
          elasticity: 0,
          velocity_z: rand * 0.5,
      }.merge! options

      super options
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