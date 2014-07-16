class Gcp < ActiveRecord::Base
  belongs_to :map

 # named_scope  :soft, :conditions => {:soft => true}
 # named_scope  :hard, :conditions => ["gcps.soft IS NULL OR gcps.soft = 'F'"]
  scope :softs, -> { where(:soft => true)}
  scope :hards, -> { where('soft IS NULL OR soft = ?', false) }

end


