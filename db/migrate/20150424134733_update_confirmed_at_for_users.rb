class UpdateConfirmedAtForUsers < ActiveRecord::Migration
  def up   
     execute("UPDATE users SET confirmed_at = NOW()")
  end
end
