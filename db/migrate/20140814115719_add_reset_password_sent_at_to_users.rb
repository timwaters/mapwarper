class AddResetPasswordSentAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reset_password_sent_at, :datetime
    change_column :users, :reset_password_token, :string, :limit => nil
  end
end
