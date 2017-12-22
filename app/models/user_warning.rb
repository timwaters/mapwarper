class UserWarning < ActiveRecord::Base
  #This class is to keep track of what warnings have been given to users. 
  #notes    text
  #category string
  #status   string
  
  belongs_to :user 

  validates :user_id, uniqueness: { scope: [:category, :status], message: "already has an open warning with this category" }, if: Proc.new { |a| a.status  == "open" }

end
