class AddMediawikiCategoryFieldsToImport < ActiveRecord::Migration
  def change
    add_column :imports, :category, :string
  end
end
