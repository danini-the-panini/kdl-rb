require 'bundler/gem_tasks'
require 'rake/testtask'

file 'lib/kdl/kdl.tab.rb' => ['lib/kdl/kdl.yy'] do
  system 'bin/racc lib/kdl/kdl.yy'
end
task :racc => 'lib/kdl/kdl.tab.rb'

Rake::TestTask.new(:test => :racc) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.options = '--pride'
end

task :default => :test
