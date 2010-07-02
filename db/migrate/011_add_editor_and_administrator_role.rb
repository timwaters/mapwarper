class AddEditorAndAdministratorRole < ActiveRecord::Migration
  def self.up

    Role.create(:name => 'editor')
    Role.create(:name => 'administrator')

    role = Role.find_by_name('administrator')
    #we'll give our dummy super user admin role too, in addition to super user
    user = User.find_by_login('super')

    permission = Permission.new
    permission.role = role
    permission.user = user
    permission.save(false)

  end

  def self.down
    Role.find_by_name('administrator').destroy
    Role.find_by_name('editor').destroy

  end
end
