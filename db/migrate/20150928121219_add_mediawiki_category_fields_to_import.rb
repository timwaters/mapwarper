class AddMediawikiCategoryFieldsToImport < ActiveRecord::Migration
  def change
    add_column :imports, :category, :string
    add_column :imports, :finished_at, :datetime
    add_column :imports, :status, :integer
    add_column :imports, :save_layer, :boolean
    add_column :imports, :append_layer, :boolean
  end
end
