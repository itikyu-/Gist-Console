#!/usr/bin/env ruby
require "net/https"
require "json"
require "uri"

BASE_DOMAIN = "api.github.com"
TOKEN = File.open("#{ENV['HOME']}/.config/github_personal_token").read.chomp
PASSWORD = 'x-oauth-basic'

class Api_layer

  def initialize
    @https = Net::HTTP.new(BASE_DOMAIN, 443)
    @https.use_ssl = true
  end

  def request_get(path, param = nil)
    request = Net::HTTP::Get.new(path)
    request.basic_auth TOKEN, PASSWORD
    @response = @https.request(request)
    JSON.parse(@response.body)
  end

  def request_post(path, param)
    request = Net::HTTP::Post.new(path)
    request.basic_auth TOKEN, PASSWORD
    request.body = param.to_json
    @response = @https.request(request)
    JSON.parse(@response.body)
  end

  def success?
    @response.is_a? Net::HTTPSuccess
  end
end
