# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

before do
  @memo_infos = []
  @connect = PG.connect(host: 'localhost', dbname: 'mydb', port: '5432')
  results = @connect.exec('SELECT * FROM books')

  results.each do |result|
    @memo_infos << result
  end
end

get '/' do
  redirect to('/memos')
end

get '/memos' do
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  # 新規メモの、ID番号を決める処理。
  new_memo_id = if @memo_infos == []
                  1
                else
                  @memo_infos.max_by { |memo| memo['id'].to_i }['id'].to_i + 1
                end

  @connect.exec('INSERT INTO books VALUES ($1, $2, $3)', [new_memo_id, params['title'], params['content']])

  results = @connect.exec('SELECT * FROM books')

  results.each do |result|
    @memo_infos << result
  end

  redirect "/memos/#{new_memo_id}"
end

get '/memos/:id' do
  @memo_info = @memo_infos.find { |memo| memo['id'].to_i == params['id'].to_i }

  erb :detail
end

get '/memos/:id/edit' do
  @memo_info = @memo_infos.find { |memo| memo['id'].to_i == params['id'].to_i }
  erb :edit
end

patch '/memos/:id' do
  @connect.exec('update books set title=$1, body=$2 where id=$3', [params['title'], params['content'], params['id']])

  results = @connect.exec('SELECT * FROM books')

  results.each do |result|
    @memo_infos << result
  end

  redirect "/memos/#{params['id']}"
end

delete '/memos/:id' do
  @connect.exec("delete from books where id=#{params['id']}")
  results = @connect.exec('SELECT * FROM books')

  results.each do |result|
    @memo_infos << result
  end

  redirect '/'
end
