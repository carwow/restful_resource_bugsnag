require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Increase the revision number"
task :increase_revision_number do
  version_file = "lib/restful_resource_bugsnag/version.rb"
  file_content = File.read(version_file)
  rule = /(\d+\.\d+\.)(\d+)/
  new_revision_number = rule.match(file_content)[2].to_i + 1
  new_file_content = file_content.sub(rule, '\1' + new_revision_number.to_s)

  File.open(version_file, 'w') { |file| file.write(new_file_content) }
end
