class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.integer :role_id, :user_id, :null => false
      t.timestamps
    end

  Role.create(:name => 'super user')


  end

  def self.down

    Role.find_by_name('super user').destroy
    
    drop_table :permissions
  end
end
