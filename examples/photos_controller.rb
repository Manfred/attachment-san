class PhotosController < ActionController::Base
  before_filter :find_post

  def new
  end

  def create
    @photo = @post.photos.build params[:photo]
    if @photo.save
      flash[:hilight] = dom_id(@photo)
      redirect_to @post
    else
      render :new
    end
  end

  protected

  def find_post
    @post = Post.find params[:post_id]
  end
end