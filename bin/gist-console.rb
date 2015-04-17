#!/usr/bin/env ruby

require "optparse"
require_relative "../lib/gist"

gist = Gist.new
options = {}

subtext = <<HELP
サブコマンド一覧:
list :     一覧表示
post :     投稿
show :     詳細表示

それぞれのコマンドの詳細は 'gist-console.rb COMMAND --help'.
HELP

global = OptionParser.new do |opts|
  opts.banner = "Usage: gist-console.rb subcommand [options]"
  opts.separator ""
  opts.separator subtext
end

subcommands = { 
    'list' => OptionParser.new do |opts|
       opts.banner = "Usage: list [options]"
       opts.on("-c", "--closed", "限定公開のGistのみを表示") do |v|
         options['closed'] = v
       end
    end,
    'post' => OptionParser.new do |opts|
       opts.banner = "Usage: post [options]"
       opts.on("-c", "--closed", "限定公開として投稿") do |v|
         options['closed'] = v
       end
       opts.on("-d DESCRIPTION", "--description", "概要(必須)") do |v|
         options['desccription'] = v
       end
       opts.on("-f FILE_PATH_LIST", "--file-path-list", "投稿ファイルパスの指定(必須)") do |v|
         options['file_path_list'] = v.split(',')
       end
    end,
    'show' => OptionParser.new do |opts|
       opts.banner = "Usage: show [options]"
       opts.on("-i ID", "--id", "GistIDの指定") do |v|
         options['id'] = v
       end
    end
}
subcommands.default = OptionParser.new do |opts|
       opts.banner = "NOT SUBCOMMAND"
end


global.order!
command = ARGV.shift
subcommands[command].order!

case command
when 'list'
  gist.list(options)
when 'post'
  gist.post(options)
when 'show'
  gist.show(options)
else
  global.help
end
