#!/usr/bin/env ruby
require_relative "api_layer"
require "uri"
require "net/https"

class Gist

  def initialize 
    @api = Api_layer.new
  end

  # 一覧表示
  def list(option)
    gists = @api.request_get('/gists')
    gists.each do |gist|
      next if gist['public'] && option['closed'] == true

      body = "GIST_ID: " + gist['id']
      body += "(secret)" unless gist['public']
      body += "\n"
      gist['files'].each do |name, data|
        body += "#{name}[#{data['language']}]  "
      end
      body += "\n    Description: #{gist['description']}\n\n"
      puts body
    end
  end

  # 詳細表示
  def show(option)
    id = option['id']
    gists = @api.request_get('/gists')
    gists.each do |gist|
      if gist['id'][0, id.length] == id then
        gist['files'].each do |name, data|
          puts "[[#{name}]]"
          Net::HTTP.get_print URI.parse(data['raw_url'])
          puts "\n\n"
        end
      end
    end
  end

  # 新規Gistの作成
  def post(option)
    req_body = {}
    req_body['description'] = option['description']
    req_body['public'] = option['closed'] == true ? false : true
    req_body['files'] = {}
    option['file_path_list'].each do |file_path|
      req_body['files'][File.basename(file_path)] = {content: File.open(file_path).read}
    end

    msg = @api.request_post('/gists', req_body)
    if @api.success? then
      puts "Posted Successfully!"
    else
      puts msg
    end
  end
end
