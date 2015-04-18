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

  def post_gist(path, param)
    request = Net::HTTP::Post.new(path)
    request.basic_auth TOKEN, PASSWORD
    request.body = param.to_json
    @response = @https.request(request)
    JSON.parse(@response.body)
  end


  def success?
    @response.is_a? Net::HTTPSuccess
  end

  def header_value(key)
    @response.get_fields(key)
  end 

  def get_all_gist(path, param = nil)
    request = Net::HTTP::Get.new(path)
    request.basic_auth TOKEN, PASSWORD
    @response = @https.request(request)
    result = Array.new(1, JSON.parse(@response.body))
    return result[0] if @response.get_fields('link').nil? 

    page_range = @response.get_fields('link')[0].scan(/page=(.*?)>/).flatten.map(&:to_i)
    (page_range[0]..page_range[1]).each do |p|
      request = Net::HTTP::Get.new(path + "?page=" + p.to_s)
      request.basic_auth TOKEN, PASSWORD
      @response = @https.request(request)
      result << JSON.parse(@response.body)
    end

    result.inject(:+)
  end

  private

  def anonymous_request_get(path, param = nil)
    request = Net::HTTP::Get.new(path)
    @response = @https.request(request)
    JSON.parse(@response.body)
  end

  def anonymous_request_post(path, param)
    request = Net::HTTP::Post.new(path)
    request.body = param.to_json
    @response = @https.request(request)
    JSON.parse(@response.body)
  end
end
