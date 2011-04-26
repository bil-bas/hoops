module Hoops
  # 2.5D object.
  class BaseObject < GameObject
    SHADOW_ALPHA = 0.5

    attr_reader :z
    attr_writer :z

    def casts_shadow?; @casts_shadow; end

    public
    def initialize(options = {})
      options = {
          rotation_center: :bottom_center,
          casts_shadow: true,
          z: 0,
      }.merge! options

      @casts_shadow = options[:casts_shadow]
      @z = options[:z]

      super options
    end

    public
    def draw
      # Draw a shadow
      if casts_shadow?
        color = Color.rgba(0, 0, 0, (alpha * SHADOW_ALPHA).round)
        shadow_scale = 0.5
        shadow_height = height * shadow_scale
        shadow_base = z * shadow_scale
        skew = shadow_height * shadow_scale

        top_left = [x + skew + (z * shadow_scale), y - shadow_height - shadow_base, color]
        top_right = [x + skew + width + (z * shadow_scale), y - shadow_height - shadow_base, color]
        bottom_left = [x - (width - z) * shadow_scale, y - shadow_base, color]
        bottom_right = [x + (width + z) * shadow_scale, y - shadow_base, color]

        if factor_x > 0
          image.draw_as_quad(*top_left, *top_right, *bottom_left, *bottom_right, ZOrder::SHADOWS)
        else
          image.draw_as_quad(*top_right, *top_left, *bottom_right, *bottom_left, ZOrder::SHADOWS)
        end
      end

      image.draw_rot(x, y - z, y, 0, 0.5, 1, @factor_x, @factor_y, @color, @mode)
    end

    # Shatter the object into its component pixel fragments.
    public
    def explode(type)
      no_color = Color.rgb(255, 255, 255)

      image.explosion.each do |color, x, y|
        effective_color = if self.color == no_color
                            color.dup
                          else
                            self.color.dup
                          end

        # Allow for direction of facing.
        x = factor_x > 0 ? (self.x - width / 2.0 + x) : (self.x + width / 2.0 - x)

        type.create(x: x,
                    y: self.y,
                    z: z + height - y,
                    color: effective_color)
      end
    end
  end
end