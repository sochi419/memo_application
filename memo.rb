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
    @memo_infos = (JSON.load(file))['memos']
  end
end

get '/' do
  erb :index
end

get '/show/:id' do
  @memo_infos.each do |memo|
    @memo_info = memo['id'].to_i == params['id'].to_i ? memo : @memo_info
  end
  erb :show
end

get '/edit/:id' do
  @memo_infos.each do |memo|
    @memo_info = memo['id'].to_i == params['id'].to_i ? memo : @memo_info
  end
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
    @memo_infos.each do |memo|
      @memo_info = memo['id'].to_i == params['id'].to_i ? memo : @memo_info
    end
    @memo_infos.delete(@memo_info)

    json = { memos: @memo_infos }
    JSON.dump(json, file)
  end

  redirect '/'
end

get '/new' do
  erb :new
end

post '/create' do
  # 新規メモの、ID番号を決める処理。
  if @memos['memos'] == []
    new_memo_id = 1
  else
    id_aggregation = @memos['memos'].map { |memo| memo['id'].to_i }
    new_memo_id = (id_aggregation.max + 1)  # 「既存メモの最大ID + 1」 に新規メモのIDを設定する。
  end

  File.open('memo.json', 'w') do |file|
    @memo_infos << { 'id' => new_memo_id.to_s, 'title' => params['title'].to_s, 'body' => params['content'].to_s }

    json = { memos: @memo_infos }
    JSON.dump(json, file)
  end

  redirect "/show/#{new_memo_id}"
end
