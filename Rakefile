desc "Run all specs by default"
task :default => :spec

desc "Run all specs"
task :spec do
  require 'bacon'

  Bacon.extend Bacon::SpecDoxOutput
  Bacon.summary_on_exit

  Dir[File.dirname(__FILE__) + '/test/**/spec_*.rb'].each do |file|
    load file
  end
end