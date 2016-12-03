class CommentsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :check_administrator_role, :only => [:index]
 

  rescue_from ActiveRecord::RecordNotFound, :with => :bad_record
  helper :sort
  include SortHelper

  def index
    @html_title = t('.title')
    sort_init 'created_at'
    sort_update
    @query = params[:query]

    @comments = Comment.order(sort_clause).paginate(:page => params[:page], :per_page => 30)
    
    respond_to do | format |
      format.html {}
    end
  end
  
  def destroy
    comment = Comment.find(params[:id])
    commentable = comment.commentable
    if (comment.user == current_user) or admin_authorized?
      if comment.destroy
        flash.now[:notice] = t('.flash')
      else
        flash.now[:notice] = t('.error')
      end
    end
    redirect_to polymorphic_path(commentable, :anchor => "#{t('layouts.tabs.comments')}_tab")
  end

  def create
    commentable_type = params[:commentable][:commentable]
    commentable_id = params[:commentable][:commentable_id]
    # Get the object that you want to comment
    commentable = Comment.find_commentable(commentable_type, commentable_id)
    #
    # Create a comment with the user submitted content
    comment = Comment.new(comment_params)
    # Assign this comment to the logged in user
    comment.user_id = current_user.id

    # Add the comment
    commentable.comments << comment
    
    redirect_to polymorphic_path(commentable, :anchor => "#{t('layouts.tabs.comments')}_tab")
  end

  private
  def bad_record
    #logger.error("not found #{params[:id]}")
    respond_to do | format |
      format.html do
        flash[:notice] = t('comments.show.not_found')
        redirect_to :root
      end
      format.json {render :json => {:stat => "not found", :items =>[]}.to_json, :status => 404}
    end
  end

  def comment_params
    params.require(:comment).permit(:comment)
  end


end
