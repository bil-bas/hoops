Config = RbConfig if defined? RbConfig and not defined? Config # 1.9.3 hack

require 'rake/clean'
require 'redcloth'

OSX_GEMS = %w[chingu fidgit clipboard] # Source gems for inclusion in the .app package.

APP = "hoops"
APP_READABLE = "HOOPS!"
require_relative "lib/#{APP}/version"
RELEASE_VERSION = Hoops::VERSION


README_TEXTILE = "README.textile"
README_HTML = "README.html"
CHANGELOG_FILE = "CHANGELOG.txt"
#LICENSE_FILE = "COPYING.txt"
SOURCE_FOLDERS = %w[bin lib media]
EXTRA_SOURCE_FILES = [".gitignore", "Rakefile", README_TEXTILE, "Gemfile", "Gemfile.lock"]
README_FILE = README_HTML


RELEASE_FOLDER = 'pkg'
RELEASE_FOLDER_BASE = File.join(RELEASE_FOLDER, "#{APP}_v#{RELEASE_VERSION.gsub(/\./, '_')}")

CLEAN.include("*.log")
CLOBBER.include("doc/**/*", README_HTML)

begin
  # My scripts which help me package games.
  require_relative "../release_packager/lib/release_packager"
rescue LoadError
end

desc "Generate Yard docs."
task :yard do
  system "yard doc lib"
end

# Generate a friendly readme
file README_HTML => :readme
desc "Convert readme to HTML"
task readme: README_TEXTILE do
  puts "Converting readme to HTML"
  File.open(README_HTML, "w") do |file|
    file.write RedCloth.new(File.read(README_TEXTILE)).to_html
  end
end





