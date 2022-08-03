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
  File.open('memo.json') do |file|
    @memo_infos = (JSON.parse(file.read))['memos']
  end
end

get '/' do
  erb :index
end

get '/detail/:id' do
  @memo_info = @memo_infos.find { |memo| memo['id'].to_i == params['id'].to_i }

  erb :detail
end

get '/edit/:id' do
  @memo_info = @memo_infos.find { |memo| memo['id'].to_i == params['id'].to_i }
  erb :edit
end

patch '/edit/:id' do
  File.open('memo.json', 'w') do |file|
    memo_inputs = @memo_infos.map do |memo|
      if memo['id'] == params['id'].to_s # 編集中のメモは、ユーザーの入力内容を反映させた内容を、memo_inputsに代入。
        { 'id' => params['id'].to_s, 'title' => params['title'].to_s, 'body' => params['content'].to_s }
      else
        memo # 編集中ではないメモは、そのままmemo_inputsに代入。
      end
    end

    json = { memos: memo_inputs }
    JSON.dump(json, file)
  end

  redirect "/detail/#{params['id']}"
end

delete '/show/:id' do
  File.open('memo.json', 'w') do |file|
    @memo_infos.delete_if { |memo| memo['id'].to_i == params['id'].to_i }

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
  if @memo_infos == []
    new_memo_id = 1
  else
    id_aggregation = @memo_infos.map { |memo| memo['id'].to_i }
    new_memo_id = (id_aggregation.max + 1)  # 「既存メモの最大ID + 1」 に新規メモのIDを設定する。
  end

  File.open('memo.json', 'w') do |file|
    @memo_infos << { 'id' => new_memo_id.to_s, 'title' => params['title'].to_s, 'body' => params['content'].to_s }

    json = { memos: @memo_infos }
    JSON.dump(json, file)
  end

  redirect "/detail/#{new_memo_id}"
end
