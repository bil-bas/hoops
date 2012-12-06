require_relative "pet"

module Hoops
  class Cat < Pet
    def initialize(command, options = {})
      super command, "pet_cat_#{rand(2) + 1}_16x16.png", options
    end
  end
end