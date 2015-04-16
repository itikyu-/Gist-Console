#!/usr/bin/env ruby
require "net/https"
require "json"

BASE_DOMAIN = "api.github.com"
TOKEN = File.open("#{ENV['HOME']}/.config/github_personal_token").read.chomp
PASSWORD = 'x-oauth-basic'

class Gist

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
         print "#{name}[#{data['language']}], "
       end
       puts "\n    Description: #{gist['description']}\n\n"
     end
   }
  end

end
