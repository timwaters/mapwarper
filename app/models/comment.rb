class Comment < ActiveRecord::Base

  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true
  
  default_scope -> { order('created_at ASC') }

  # NOTE: Comments belong to a user
  belongs_to :user

end
