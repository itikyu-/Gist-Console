#!/usr/bin/env ruby
# encoding: utf-8

require_relative "api_layer"
require "uri"
require "net/https"

# APIへ渡すパラメータの整形
# APIから返ってきたデータの整形・出力を行います
class Gist

  def initialize
    @api = Api_layer.new
  end

  # 一覧表示
  # SUBCOMMAND: list
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
  # SUBCOMMAND: show
  def show(option)
    id = option['id']
    if id.length < 20 then
      gists = @api.get_all_gist
      gist = search_id(gists, id)
    else
      gist = search_with_complete_id(id)
    end

    if option['file'] == true
      write_files('./', gist)
    elsif option['exec'] == true
      write_files('/tmp/', gist)
      commands = []
      gist['files'].each do |name, data|
        lang = data['language'] == nil ? 'text' : data['language'].downcase
        commands << "#{lang} /tmp/#{name}" if lang != 'text'
        commands.each do |com|
          puts "EXEC: #{com}"
          puts `#{com}`
        end
      end
    elsif option['script'] == true
      puts "<script src=\"#{gist['html_url']}.js\"></script>"
    elsif option.has_key? 'clone'
      option['clone'] == "" if option['clone'] == nil
      system "git clone #{gist['git_pull_url']} #{option['clone']}"
    else
      gist['files'].each do |name, data|
        puts "[[#{name}]]"
        puts @api.get_raw(data['raw_url'])
        puts "\n\n"
      end
    end
  end

  # 新規Gistの作成
  # SUBCOMMAND: post
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

  # Gistの削除
  # SUBCOMMAND: delete
  def delete(option)
    id = option['id']
    if id.length < 20 then
      gists = @api.get_all_gist
      gist = search_id(gists, id)
      confirm!(gist['id'], gist)
      response = @api.delete_the_gist(gist['id'])
    else
      confirm!(id)
      response = @api.delete_the_gist(id)
    end

    if @api.success? then
      puts "削除成功しました!"
    else
      puts "削除失敗しました...", response.body
    end
  end
  
  private

  # gistアウトラインの表示
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

  # gist一覧から特定のGistIDで検索
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

  # 完全なGistIDで検索
  def search_with_complete_id(id)
    gist = @api.get_the_gist(id)

    if @api.success? then
      return gist
    else 
      puts "見つかりませんでした。"
      exit
    end
  end

  # ローカルファイルへGistの保存
  def write_files(base_path, gist)
      gist['files'].each do |name, data|
        File.open(name, "w") do |f|
          f.puts @api.get_raw(data['raw_url'])
        end
      end
  end

  # 対象にしているGistが間違っていないか、確認をする。
  # 間違っていた場合は処理を強制終了する。
  def confirm!(id, gist = nil)
    gist = search_with_complete_id(id) if gist == nil

    print_outline([gist])
    print "対象は間違いありませんか? [Y/n]:"

    if gets.chomp.casecmp("y") == 0 then
      return true
    else
      puts "終了します。"
      exit
    end
  end

end
