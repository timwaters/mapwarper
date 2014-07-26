class Gcp < ActiveRecord::Base
  belongs_to :map
  audited :allow_mass_assignment => true
 # named_scope  :soft, :conditions => {:soft => true}
 # named_scope  :hard, :conditions => ["gcps.soft IS NULL OR gcps.soft = 'F'"]
  scope :soft, -> { where(:soft => true)}
  scope :hard, -> { where('soft IS NULL OR soft = ?', false) }

end


