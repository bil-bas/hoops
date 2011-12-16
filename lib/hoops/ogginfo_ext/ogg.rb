# module_name can't be auto-converted into a string (in 1.9.2, I assume).

module Ogg
  class << self
    def detect_codec(input)
      if input.kind_of?(Page)
        first_page = input
      else
        first_page = Page.read(input)
        input.rewind
      end

      codecs = Ogg::Codecs.constants.map { |module_name| Ogg::Codecs.class_eval(module_name.to_s) }.select { |c| c.is_a?(Class) }
      codec = codecs.detect { |c| c.match?(first_page.segments.first) }
      unless codec
        raise(StreamError,"unknown codec")
      end

      return codec
    end
  end
end