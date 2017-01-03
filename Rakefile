require 'rake'
require 'rake/contrib/sshpublisher'

files = ['plugin/surround.vim', 'doc/surround.txt']

desc "Install"
task :install do
  vimfiles = if ENV['VIMFILES']
               ENV['VIMFILES']
             elsif RUBY_PLATFORM =~ /(win|w)32$/
               File.expand_path("~/vimfiles")
             else
               File.expand_path("~/.vim")
             end

  puts "Installing surround.vim"
  files.each do |file|
    target_file = File.join(vimfiles, file)
    FileUtils.mkdir_p(File.dirname(target_file))
    FileUtils.cp(file, target_file)
    puts "  Copied #{file} to #{target_file}"
  end

  puts "Regenerating helptags"
  `vim -c 'helptags #{vimfiles}/doc' -c q 2> /dev/null`
  # '2> /dev/null' to suppress the following message:
  # "Vim: Warning: Output is not to a terminal"
  puts "  Processed #{vimfiles}/doc directory"
end

task :default => [:install]
