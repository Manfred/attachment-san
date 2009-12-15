require 'rake/rdoctask'
require 'rake/testtask'

desc "Run all tests by default"
task :default => :test

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name     = "attachment-san"
    s.homepage = "http://github.com/Fingertips/attachment-san"
    s.email    = ["eloy@fngtps.com", "manfred@fngtps.com"]
    s.authors  = ["Eloy Duran", "Manfred Stienstra"]
    s.summary  = s.description = "Rails plugin for easy and rich attachment manipulation."
    s.files   -= %w{ .gitignore .kick }
  end
rescue LoadError
end

namespace :docs do
  begin
    require 'rubygems'
    gem 'rdoc', '>= 2'
    
    Rake::RDocTask.new(:generate) do |rdoc|
      rdoc.title = "AttachmentSan"
      rdoc.main  = "README"
      rdoc.rdoc_files.include("README", "LICENSE", "lib/**/*.rb")
      rdoc.options << "--all" << "--charset=utf-8" << "--format=darkfish"
    end
  rescue LoadError
    puts "[!] In order to generate docs, please install the `rdoc 2.x.x' and `darkfish-rdoc' gems."
  end
end