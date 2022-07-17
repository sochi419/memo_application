# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

before do
  @memos = File.open('memo.json') { |f| JSON.load(f) }

  File.open('memo.json') do |file|
    hash = JSON.load(file)
    @hashes = hash['memos']
  end
end

get '/' do
  @hashes.each do |hash|
    hash['title'] = h(hash['title'])
  end

  erb :index
end

get '/show/:id' do
  # 複数のメモの中で、表示したいメモ(idが一致するもの)を@hashに代入する。
  keyword = params['id'].to_s
  @hash = @hashes.find { |x| x['id'].match?(keyword) }
  @hash['title'] = h(@hash['title'])
  @hash['body'] = h(@hash['body'])

  erb :show
end

get '/edit/:id' do
  keyword = params['id'].to_s
  @hash = @hashes.find { |x| x['id'].match?(keyword) }
  erb :edit
end

patch '/edit/:id' do
  File.open('memo.json', 'w') do |file|
    memo_inputs = [] # 配列memo_inputsに、メモの内容を入れていく。

    @memos['memos'].each do |memo|
      memo_inputs << if memo['id'] == params['id'].to_s # 編集中のメモは、ユーザーの入力内容を反映させた内容を、memo_inputsに代入。
                       { 'id' => params['id'].to_s, 'title' => params['title'].to_s, 'body' => params['content'].to_s }
                     else
                       memo # 編集中ではないメモは、そのままmemo_inputsに代入。
                     end
    end

    json = { memos: memo_inputs }
    JSON.dump(json, file)
  end

  redirect "/show/#{params['id']}"
end

delete '/show/:id' do
  File.open('memo.json', 'w') do |file|
    keyword = params['id'].to_s
    @hash = @hashes.find { |x| x['id'].match?(keyword) }
    @hashes.delete(@result)

    json = { memos: @hashes }
    JSON.dump(json, file)
  end

  redirect '/'
end

get '/new' do
  erb :new
end

post '/create' do
  # 新規メモの、ID番号を決める処理。
  id_aggregation = []

  @memos['memos'].each do |memo|
    id_aggregation << memo['id']
  end

  # 「既存メモの最大ID + 1」 に新規メモのIDを設定する。
  new_memo_id = (id_aggregation.max.to_i + 1)

  File.open('memo.json', 'w') do |file|
    @hashes << { 'id' => new_memo_id.to_s, 'title' => params['title'].to_s, 'body' => params['content'].to_s }

    json = { memos: @hashes }
    JSON.dump(json, file)
  end

  redirect "/show/#{new_memo_id}"
end
