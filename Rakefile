require 'rake/testtask'


Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/test_*.rb']
  t.warning = true
end

task :build do
  require 'fileutils'

  if Dir.exist?('build')
    path = File.join('build', '*.gem')
    FileUtils.rm(Dir.glob(path))
  else
    Dir.mkdir('build')
  end

  Dir.chdir('build') do
    puts `gem build ../dimples.gemspec`
  end
end

task :publish do
  puts `gem push build/*.gem`
end