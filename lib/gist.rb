#!/usr/bin/env ruby
require "net/https"
require "json"
require "uri"

BASE_DOMAIN = "api.github.com"
TOKEN = File.open("#{ENV['HOME']}/.config/github_personal_token").read.chomp
PASSWORD = 'x-oauth-basic'

class Gist

  # 一覧表示
  def list
   https = Net::HTTP.new(BASE_DOMAIN, 443)
   https.use_ssl = true
   https.start {
     request = Net::HTTP::Get.new('/gists')
     request.basic_auth TOKEN, PASSWORD
     response = https.request(request)
     gists = JSON.parse(response.body)
     gists.each do |gist|
       puts "GIST_ID: #{gist['id']}"
       gist['files'].each do |name, data|
         print "#{name}[#{data['language']}]  "
       end
       puts "\n    Description: #{gist['description']}\n\n"
     end
   }
  end

  # 詳細表示
  def show(option)
   id = option['id']
   https = Net::HTTP.new(BASE_DOMAIN, 443)
   https.use_ssl = true
   https.start {
     request = Net::HTTP::Get.new('/gists')
     request.basic_auth TOKEN, PASSWORD
     response = https.request(request)
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

  # 詳細表示
  def show(option)
   id = option['id']
   https = Net::HTTP.new(BASE_DOMAIN, 443)
   https.use_ssl = true
   https.start {
     request = Net::HTTP::Get.new('/gists')
     request.basic_auth TOKEN, PASSWORD
     response = https.request(request)
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
end
