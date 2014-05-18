# coding: utf-8

class PostsController < ApplicationController

  # 認証フィルター
  before_filter :authenticate_user!

  def index
    @search_form = SearchForm.new (params[:search_form])
    @posts = Post.scoped(:order => "created_at ASC").page(params[:page]).per(4)

    if @search_form.q.present?
      # 検索対象の日付をフォームタグから取得
      to   = Date.new(params[:to][:year].to_i,
                      params[:to][:month].to_i,
                      #日付のみ指定だと０時扱いになる為？、＋１日して指定日も検索対象とする。
                      params[:to][:day].to_i + 1) 
      from = Date.new(params[:from][:year].to_i,
                      params[:from][:month].to_i,
                      params[:from][:day].to_i)
      @posts = Post.scoped(:order => "created_at ASC", :conditions =>{:updated_at => from..to}).page(params[:page]).per(4)
      @posts = @posts.content_or_title_matches @search_form.q
    end
  end

  def show
    @post = Post.find(params[:id])
    @comment = Post.find(params[:id]).comments.build
  end

  def new
   @post = Post.new
  end

  def create
    @post = Post.new(params[:post])
    if @post.save
      redirect_to posts_path, notice: 'succsess!!!'
    else
      render action: 'new'
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if @post.update_attributes(params[:post])
      redirect_to posts_path, notice: 'Edit OK'
    else
      render action: 'edit'
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    render json: { post: @post }
  end
end
