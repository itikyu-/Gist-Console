#!/usr/bin/env ruby
require "net/https"
require "json"
require "uri"

BASE_DOMAIN = "api.github.com"
TOKEN = File.open("#{ENV['HOME']}/.config/github_personal_token").read.chomp
PASSWORD = 'x-oauth-basic'

# GitHubのAPIと直接のやり取りを行う
# HTTP関連の処理はこちらに集約してGistクラスからはHTTPを隠蔽
class Api_layer

  def initialize
    @https = Net::HTTP.new(BASE_DOMAIN, 443)
    @https.use_ssl = true
  end

  # IDを完全指定してGistを取得
  def get_the_gist(id)
    request = Net::HTTP::Get.new('/gists/' + id)
    request.basic_auth TOKEN, PASSWORD
    @response = @https.request(request)

    unless success?
      puts "見つかりませんでした。"
      exit
    end
    JSON.parse(@response.body)
  end

  # IDを完全指定してGistを削除
  def delete_the_gist(id)
    request = Net::HTTP::Delete.new('/gists/' + id)
    request.basic_auth TOKEN, PASSWORD
    @response = @https.request(request)
  end

  # 全Gist一覧を取得
  # 1度に30件までのGistの取得になるため、30件以上存在している場合は
  # ResponseHeaderのlinkフィールドを確認して続きを取得する
  def get_all_gist
    request = Net::HTTP::Get.new('/gists')
    request.basic_auth TOKEN, PASSWORD
    @response = @https.request(request)
    result = Array.new(1, JSON.parse(@response.body))
    return result[0] if @response.get_fields('link').nil? 

    page_range = @response.get_fields('link')[0].scan(/page=(.*?)>/).flatten.map(&:to_i)
    (page_range[0]..page_range[1]).each do |p|
      request = Net::HTTP::Get.new("/gists?page=" + p.to_s)
      request.basic_auth TOKEN, PASSWORD
      @response = @https.request(request)
      result << JSON.parse(@response.body)
    end

    result.inject(:+)
  end

  # Gistを投稿する。
  # 成功時にはGitHub上の該当URLと埋め込み用のScriptタグを返す
  def post_gist(path, param)
    request = Net::HTTP::Post.new(path)
    request.basic_auth TOKEN, PASSWORD
    request.body = param.to_json
    @response = @https.request(request)

    if success?
      gist = JSON.parse(@response.body)
      str = <<-"EOS"
        Posted Successfully!
        URL:
        #{gist['html_url']}
        Embeded:
        <script src=\"#{gist['html_url']}.js\"></script>
      EOS
    else 
      str = <<-"EOS"
        Failed!
        #{JSON.parse(@response.body)}
      EOS
    end
    return str
  end

  # 認証不要な任意のURLを叩いて結果を返す
  def get_raw(url)
    Net::HTTP.get URI.parse(url)
  end

  # ヘッダーから値を取得
  def header_value(key)
    @response.get_fields(key)
  end 

  # APIのリターンコードが200系であることを確認
  def success?
    @response.is_a? Net::HTTPSuccess
  end

  private

  # 非認証APIを叩く用(GET)
  def anonymous_request_get(path, param = nil)
    request = Net::HTTP::Get.new(path)
    @response = @https.request(request)
    JSON.parse(@response.body)
  end

  # 非認証APIを叩く用(POST)
  def anonymous_request_post(path, param)
    request = Net::HTTP::Post.new(path)
    request.body = param.to_json
    @response = @https.request(request)
    JSON.parse(@response.body)
  end
end
