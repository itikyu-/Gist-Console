#!/usr/bin/env ruby
require "net/https"
require "json"
require "uri"

BASE_DOMAIN = "api.github.com"
TOKEN = File.open("#{ENV['HOME']}/.config/github_personal_token").read.chomp
PASSWORD = 'x-oauth-basic'

class Gist

  def initialize 
    @https = Net::HTTP.new(BASE_DOMAIN, 443)
    @https.use_ssl = true
  end

  # 一覧表示
  def list(option)
    @https.start {
      request = Net::HTTP::Get.new('/gists')
      request.basic_auth TOKEN, PASSWORD
      response = @https.request(request)
      gists = JSON.parse(response.body)
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
    }
  end

  # 詳細表示
  def show(option)
    id = option['id']
    @https.start {
      request = Net::HTTP::Get.new('/gists')
      request.basic_auth TOKEN, PASSWORD
      response = @https.request(request)
      gists = JSON.parse(response.body)
      gists.each do |gist|
        if gist['id'][0, id.length] == id then
          gist['files'].each do |name, data|
            puts "[[#{name}]]"
            Net::HTTP.get_print URI.parse(data['raw_url'])
            puts "\n\n"
          end
        end
      end
    }
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

    @https.start {
      request = Net::HTTP::Post.new('/gists')
      request.basic_auth TOKEN, PASSWORD
      request.body = req_body.to_json
      response = @https.request(request)
      puts response.body
    }
  end
end
