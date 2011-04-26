module Gosu
  class Song
    # Bug-fix. Song[] doesn't like full-pathed file-names.
    class << self
      alias_method :old_indexer, :[]

      def [](file)
        song = old_indexer(file)
        song ? song : new($window, file)
      end
    end
  end
end