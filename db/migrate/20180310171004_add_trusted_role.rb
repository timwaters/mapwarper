class AddTrustedRole < ActiveRecord::Migration
  def change
    Role.create(:name => 'trusted')
  end
end
