# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

class Memo
  def initialize
    @connect = PG.connect(host: 'localhost', dbname: 'mydb', port: '5432')
  end

  def list
    @connect.exec('select * from books order by id asc').to_a
  end

  def insert(new_memo_id, title, content)
    @connect.exec('INSERT INTO books VALUES ($1, $2, $3)', [new_memo_id, title, content])
  end

  def update(title, content, id)
    @connect.exec('update books set title=$1, body=$2 where id=$3', [title, content, id])
  end

  def delete(id)
    @connect.exec('delete from books where id=$1', [id])
  end
end

get '/' do
  redirect to('/memos')
end

get '/memos' do
  memo = Memo.new
  @memos = memo.list

  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  memo = Memo.new
  @memos = memo.list

  # 新規メモの、ID番号を決める処理。
  if @memos == []
    new_memo_id = 1
  else
    id_aggregation = @memos.map { |data| data['id'].to_i }
    new_memo_id = (id_aggregation.max + 1) # 「既存メモの最大ID + 1」 に新規メモのIDを設定する。
  end

  memo.insert(new_memo_id, params['title'], params['content'])

  redirect "/memos/#{new_memo_id}"
end

get '/memos/:id' do
  memo = Memo.new
  @memo = memo.list.find { |data| data['id'].to_i == params['id'].to_i }

  erb :detail
end

get '/memos/:id/edit' do
  memo = Memo.new
  @memo = memo.list.find { |data| data['id'].to_i == params['id'].to_i }
  erb :edit
end

patch '/memos/:id' do
  memo = Memo.new
  memo.update(params['title'], params['content'], params['id'])
  @memos = memo.list

  redirect "/memos/#{params['id']}"
end

delete '/memos/:id' do
  memo = Memo.new
  memo.delete(params['id'])
  @memos = memo.list

  redirect '/'
end
