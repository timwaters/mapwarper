class AddDeveloperRole < ActiveRecord::Migration
  def self.up
    Role.create(:name => 'developer')
  end

  def self.down
    Role.find_by_name('developer').destroy
  end
end
