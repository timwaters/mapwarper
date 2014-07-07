class AddEditorAndAdministratorRole < ActiveRecord::Migration
  def self.up
    Role.create(:name => 'editor')
    Role.create(:name => 'administrator')
  end

  def self.down
    Role.find_by_name('administrator').destroy
    Role.find_by_name('editor').destroy

  end
end
