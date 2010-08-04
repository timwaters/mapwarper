class CommentsController < ApplicationController

  before_filter :login_required
  #before_filter :check_administrator_role, :only => [:index]

  rescue_from ActiveRecord::RecordNotFound, :with => :bad_record
  helper :sort
  include SortHelper

  def index
    @html_title = "Comments"
    sort_init 'created_at'
    sort_update
    @query = params[:query]

    @comments = Comment.paginate(:page => params[:page],
      :per_page => 30,
      :order => sort_clause
    )
    respond_to do | format |
      format.html {}
    end
  end
  
  def destroy
    comment = Comment.find(params[:id])
    commentable = comment.commentable
    if (comment.user == current_user) or admin_authorized?
      if comment.destroy
        flash.now[:notice] = "Comment deleted"
      else
        flash.now[:notice] = "Comment couldn't be deleted"
      end
    end
    redirect_to polymorphic_path(commentable, :anchor => "Comments_tab")
  end

  def add_comment
    commentable_type = params[:commentable][:commentable]
    commentable_id = params[:commentable][:commentable_id]
    # Get the object that you want to comment
    commentable = Comment.find_commentable(commentable_type, commentable_id)
    #
    # Create a comment with the user submitted content
    comment = Comment.new(params[:comment])
    # Assign this comment to the logged in user
    comment.user_id = current_user.id

    # Add the comment
    commentable.comments << comment
    
    redirect_to polymorphic_path(commentable, :anchor => "Comments_tab")
  end

private
 def bad_record
      #logger.error("not found #{params[:id]}")
     respond_to do | format |
      format.html do
       flash[:notice] = "Comment not found"
       redirect_to :root
      end
     format.json {render :json => {:stat => "not found", :items =>[]}.to_json, :status => 404}
     end
 end 



end
