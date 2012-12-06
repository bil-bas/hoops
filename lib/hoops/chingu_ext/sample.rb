module Gosu
  class Sample
    class << self
      attr_accessor :volume
    end
    self.volume = 0.5

    alias_method :old_play, :play

    def play(volume = 1, speed = 1, looping = false)
      old_play(volume * self.class.volume, speed, looping)
    end
  end
end