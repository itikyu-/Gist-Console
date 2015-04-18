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
    gists = @api.get_all_gist
 
    gists.select! do  |gist|
      next if  option['closed'] == true && gist['public'] 
      
      unless option['description'] == nil then
        next unless option['description'].all? do |word|
          gist['description'].include? word
        end
      end

      unless option['language'] == nil then
        langs = gist['files'].map do |name, data| 
          data['language']
        end.compact.uniq.map(&:upcase)
        option['language'].map!(&:upcase)
        next unless (langs & option['language']).length >= 1
      end

      true
    end 

    print_outline gists
  end

  # 詳細表示
  def show(option)
    id = option['id']
    if id.length < 20 then
      gists = @api.get_all_gist
      gist = search_id(gists, id)
    else
      gist = @api.get_the_gist(id)
    end

    if option['file'] == true
      gist['files'].each do |name, data|
        File.open(name, "w") do |f|
          f.puts Net::HTTP.get(URI.parse(data['raw_url']))
        end
      end
    elsif option['exec'] == true
      commands = []
      gist['files'].each do |name, data|
        File.open("/tmp/"+name, "w") do |f|
          f.puts Net::HTTP.get(URI.parse(data['raw_url']))
        end
        lang = data['language'] == nil ? 'text' : data['language'].downcase
        commands << "#{lang} /tmp/#{name}" if lang != 'text'
        commands.each do |com|
          puts "EXEC: #{com}"
          puts `#{com}`
        end
      end
    elsif option['script'] == true
      puts "<script src=\"#{gist['html_url']}.js\"></script>"
    else
      gist['files'].each do |name, data|
        puts "[[#{name}]]"
        puts @api.get_raw(data['raw_url'])
        puts "\n\n"
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

    puts @api.post_gist('/gists', req_body)
  end

  private
  def print_outline(gists)
    gists.each do |gist|
      body = "GIST_ID: \e[31m" + gist['id'] + "\e[0m"
      body += "(secret)" unless gist['public']
      body += "\n"
      gist['files'].each do |name, data|
        body += "#{name}[#{data['language']}]  "
      end
      body += "\n    Description: #{gist['description']}\n\n"
      puts body
    end
  end

  def search_id(gists, id)
    gists.select! do |gist|
      gist['id'][0, id.length] == id
    end
    if gists.length == 0
      puts "見つかりませんでした。"
      exit
    elsif gists.length > 1
      print_outline gists
      puts "複数ヒットしました。IDを一意に定まる長さまで指定して下さい。"
      exit
    end
    gists[0]
  end
end
