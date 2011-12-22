Config = RbConfig if defined? RbConfig and not defined? Config # 1.9.3 hack

require 'rake/clean'

APP = "hoops"
APP_READABLE = "HOOPS!"
require_relative "lib/#{APP}/version"
RELEASE_VERSION = Hoops::VERSION

#LICENSE_FILE = "COPYING.txt"

# My scripts which help me package games.
require_relative "../release_packager/lib/release_packager"

CLEAN.include("*.log")
CLOBBER.include("doc/**/*", README_HTML)

desc "Generate Yard docs."
task :yard do
  system "yard doc lib"
end



