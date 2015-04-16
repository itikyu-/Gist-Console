#!/usr/bin/env ruby

require "optparse"
require_relative "../lib/gist"

gist = Gist.new
opt = OptionParser.new  
option = {}

opt.on('-l', 'Gistを一覧で表示') {
  option[:command] = :list
}

opt.on('-p FILE_PATH_LIST', 'Gistの投稿') { |fpl|
  option[:command] = :post
  option["file_path_list"] = fpl.split(',')
}

opt.on('-d description', '要約') { |desc|
  option["description"] = desc
}

opt.on('-c', 'CLOSED: 非公開Gistとする') { 
  option["closed"] = true
}

opt.on('-s ID', '特定のGistを表示') {|id|
  option[:command] = :show
  option["id"] = id
}

opt.parse!(ARGV)

case option[:command] 
when :list
  gist.list
when :post
  gist.post(option)
when :show
  gist.show(option)
else
  opt.help
end
