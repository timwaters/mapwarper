class AddFinishedAtToImports < ActiveRecord::Migration
  def change
    add_column :imports, :finished_at, :datetime
  end
end
