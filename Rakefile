require 'spec/rake/spectask'
require 'rubygems'
require 'rake/gempackagetask'
require 'rake/clean'

CLEAN.include('pkg')
CLOBBER.include('pkg')

Spec::Rake::SpecTask.new

Rake::GemPackageTask.new(Gem::Specification.new do |s|
  s.name = "yadic"
  s.version = "0.1.0"
  s.author = "Ben Butler-Cole"
  s.email = "ben@bridesmere.com"
  s.files = ["README.rdoc", "lib/yadic.rb"]
  s.homepage = "http://github.com/benbc/yadic.rb"
  s.summary = "A lightweight dependency injection container."
end) {} # if you don't pass a block the task doesn't get defined
