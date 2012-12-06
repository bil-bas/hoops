module Hoops
  class Track
    DEFAULT_VOLUME = 0.3

    attr_reader :duration, :file, :name, :volume

    def user?; @user; end
    def name; File.basename(@file).chomp(File.extname(@file)).tr("_", " "); end
    def duration_string; "%d:%02d" % @duration.divmod(60); end
    def ==(other); @file == other.file; end

    # arg is hash or filename
    def initialize(file, options = {})
      options = {
          volume: DEFAULT_VOLUME,
          user: false,
      }.merge! options

      @file = file
      @volume = options[:volume]
      @user = options[:user]

      @duration = OggInfo.open(@file, &:length)
    end

    def to_data
      { file: @file, volume: @volume }
    end
  end
end