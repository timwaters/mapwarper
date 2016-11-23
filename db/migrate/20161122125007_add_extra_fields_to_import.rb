class AddExtraFieldsToImport < ActiveRecord::Migration
  def change
    add_column :imports, :finished_at, :datetime
    add_column :imports, :status, :integer
    add_column :imports, :save_layer, :boolean
    add_column :imports, :log_filename, :string
    add_attachment :imports, :metadata
  end
end
