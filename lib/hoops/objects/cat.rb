module Hoops
  class Cat < Pet
    def initialize(command, options = {})
      super command, "pet_cat_16x16.png", options
    end
  end
end