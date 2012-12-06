Config = RbConfig if defined? RbConfig and not defined? Config # 1.9.3 hack

require 'rake/clean'

CLEAN.include("*.log")
CLOBBER.include("doc/**/*")

desc "Generate Yard docs."
task :yard do
  system "yard doc lib"
end



