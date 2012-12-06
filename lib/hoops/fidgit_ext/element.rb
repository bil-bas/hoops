# Hack because I've forgotten how to do this correctly!
class Fidgit::Element
  alias_method :old_initialize, :initialize
  def initialize(options = {}, &block)
    options = { z: Float::INFINITY }.merge! options
    old_initialize options, &block
  end
end