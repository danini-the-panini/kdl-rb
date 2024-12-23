require 'bundler/gem_tasks'
require 'rake/testtask'

file 'lib/kdl/kdl.tab.rb' => ['lib/kdl/kdl.yy'] do
  raise "racc command failed" unless system 'bin/racc lib/kdl/kdl.yy'
end
task :racc => 'lib/kdl/kdl.tab.rb'

file 'lib/kdl/v1/kdl.tab.rb' => ['lib/kdl/v1/kdl.yy'] do
  raise "racc command failed (v1)" unless system 'bin/racc lib/kdl/v1/kdl.yy'
end
task :racc_v1 => 'lib/kdl/v1/kdl.tab.rb'

Rake::TestTask.new(:test => [:racc, :racc_v1]) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.options = '--pride'
end

task :default => :test
