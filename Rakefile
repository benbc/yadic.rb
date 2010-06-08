require 'spec/rake/spectask'
require 'rubygems'
require 'rubygems/commands/push_command'
require 'rake/gempackagetask'
require 'rake/clean'

gemspec = Gem::Specification.new do |s|
  s.name = "yadic"
  s.version = "0.1.2"
  s.author = "Ben Butler-Cole"
  s.email = "ben@bridesmere.com"
  s.files = ["README.rdoc", "lib/yadic.rb"]
  s.homepage = "http://github.com/benbc/yadic.rb"
  s.summary = "A lightweight dependency injection container."
end

task :default => :tested_gem
task :publish => [:clobber, :tested_gem, :push]
task :tested_gem => [:spec, :gem]

# defines :spec
Spec::Rake::SpecTask.new

# defines :gem (and others)
Rake::GemPackageTask.new(gemspec) {} # if you don't pass a block the
                                     # task doesn't get defined

desc 'Push build gem to rubygems.org'
task :push do
  Gem::Commands::PushCommand.new.send_gem "pkg/#{gemspec.full_name}.gem"
end
