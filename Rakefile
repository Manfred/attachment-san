require 'rake/testtask'

desc "Run all tests by default"
task :default => :test

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

namespace :docs do
  begin
    require 'rubygems'
    gem 'rdoc', '>= 2'
    require 'rdoc/task'
    
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