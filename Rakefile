require 'rake/rdoctask'
require 'rake/testtask'

desc "Run all tests by default"
task :default => :test

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

namespace :gem do
  desc "Build the gem"
  task :build do
    sh 'gem build nap.gemspec'
  end
  
  task :install => :build do
    sh 'sudo gem install nap-*.gem'
  end
end

namespace :docs do
  Rake::RDocTask.new(:generate) do |rd|
    rd.main = "README"
    rd.rdoc_files.include("README", "LICENSE", "lib/**/*.rb")
    rd.options << "--all" << "--charset" << "utf-8"
  end
end