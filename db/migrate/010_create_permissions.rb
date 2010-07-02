class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.integer :role_id, :user_id, :null => false
      t.timestamps
    end
 
#make sure the role migration was generated first
  #
  Role.create(:name => 'super user')
  # then add in the default admin user
#make sure you change this password later!

  user = User.new
  user.login = "super"
  user.email = "super@superxyz123.com"
  user.password = "&^lkHpassword"
  user.password_confirmation = "&^lkHpassword"
  user.save(false)
  user.send(:activate!)

  role = Role.find_by_name('super user')
  user = User.find_by_login('super')

  permission  = Permission.new
  permission.role = role
  permission.user = user
  permission.save(false)

  end

  def self.down

    Role.find_by_name('super user').destroy
    User.find_by_login('super').destroy
    drop_table :permissions
  end
end
