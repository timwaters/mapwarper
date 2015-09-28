class AddMediawikiCategoryFieldsToImport < ActiveRecord::Migration
  def change
    add_column :imports, :category, :string
    add_column :imports, :finished_at, :datetime
    add_column :imports, :status, :integer
  end
end
