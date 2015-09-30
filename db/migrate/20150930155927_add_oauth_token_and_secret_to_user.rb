class AddOauthTokenAndSecretToUser < ActiveRecord::Migration
  def change
    add_column :users, :oauth_secret, :string
    add_column :users, :oauth_token, :string
  end
end
