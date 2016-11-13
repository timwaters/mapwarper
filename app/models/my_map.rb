class MyMap < ActiveRecord::Base
belongs_to :user
belongs_to :map
validates_uniqueness_of :user_id, :scope =>  :map_id, :message => :not_unique

end
