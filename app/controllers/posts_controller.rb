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
    @categories = Category.all
    @cat = Category.find_by_id(@post.category_id)
  end

  def day
    @posts = Post.all(:order => "created_at DESC")
    @post_days = @posts.group_by { |t| t.created_at.beginning_of_day }
  end

  def day_list
    @date = params[:date]
    ymd = @date[0,4] + '-' + @date[4,2] + '-' + @date[6,2]
    @posts = Post.where(["created_at between ? and ?", "#{ymd} 00:00:00", "#{ymd} 24:00:00"]).order("created_at DESC")
  end

  def month
    @posts = Post.all(:order => "created_at DESC")
    @post_months = @posts.group_by { |t| t.created_at.beginning_of_month }
  end

  def month_list
    @date = params[:date]
    ym = @date[0,4] + '-' + @date[4,2]
    a = Date.new(:date => @date).next_month
    @posts = Post.where(["created_at between ? and ?", "#{ym}-01 00:00:00", "#{ym}-31 24:00:00"]).order("created_at DESC")
  end

  def year
    @posts = Post.all(:order => "created_at DESC")
    @post_years = @posts.group_by { |t| t.created_at.beginning_of_year }
  end

  def year_list
    @date = params[:date]
    y = @date[0,4]
    @posts = Post.where(["created_at between ? and ?", "#{y}-01-01 00:00:00", "#{y}-12-31 24:00:00"]).order("created_at DESC")
  end

  # カテゴリーリスト
  def category_list
    @categories = Post.find(:all).group_by(&:category_id)
    @post = Post.scoped(:order => "created_at DESC").page(params[:page]).per(2)
    @post_categories = @post.group_by(&:category_id)
  end

  # カテゴリー詳細
  def cat_list
    cat = params[:cat]
    @posts = Post.find(:all,:conditions => {:category_id => cat})
    @catname = Category.find(cat)
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
