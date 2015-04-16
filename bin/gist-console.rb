#!/usr/bin/env ruby

require "optparse"
require_relative "../lib/gist"

gist = Gist.new
opt = OptionParser.new  
option = {}

opt.on('-l', 'Gistを一覧で表示') {
  option[:command] = :list
}

opt.on('-p', 'Gistの投稿') {
  option[:command] = :post
}

opt.on('-s ID', '特定のGistを表示') {|id|
  option[:command] = :show
  option["ID"] = id
}

opt.parse!(ARGV)

case option[:command] 
when :list
  gist.list
when :post
  gist.post
when :show
  gist.show(option["ID"])
else
  opt.help
end
