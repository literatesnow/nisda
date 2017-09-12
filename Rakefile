require 'fileutils'

task :default => :build
task :build => ['dist']

directory 'dist'

file 'dist' do |t|
  FileUtils.cp_r 'www/static/.', t.name
end

task :clean do
  FileUtils.rm_rf 'dist'
end
