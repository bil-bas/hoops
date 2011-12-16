require_relative "base_object"

module Hoops
  class PhysicsObject < BaseObject
    GRAVITY = -5 / 1000.0 # Acceleration per second.

    def initialize(options = {})
      options = {
          velocity_z: 0,
          elasticitiy: 0.5,
      }.merge! options

      super options

      @velocity_z = options[:velocity_z]
      @elasticity = options[:elasticity]
    end

    def update
      if (@velocity_z != 0 or @z > 0)
        @velocity_z += GRAVITY * parent.frame_time
        @z += @velocity_z

        if @z <= 0
          @z = 0
          @velocity_z = - @velocity_z * @elasticity if @velocity_z < 0

          if @velocity_z < 0.2
            @velocity_z == [0, 0, 0]
          end
        end
      end

      super
    end
  end
end