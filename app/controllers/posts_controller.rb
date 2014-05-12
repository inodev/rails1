# coding: utf-8

class PostsController < ApplicationController

  # 認証フィルター
  before_filter :authenticate_user!

  def index
    @search_form = SearchForm.new (params[:search_form])
    @posts = Post.scoped(:order => "created_at ASC").page(params[:page]).per(4)

    if @search_form.q.present?
      # 検索対象 7日前〜当日
      to = Date.today
      from = to - 7
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
