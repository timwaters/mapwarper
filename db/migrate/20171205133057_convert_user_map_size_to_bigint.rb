class ConvertUserMapSizeToBigint < ActiveRecord::Migration
  def change
    change_column :users, :upload_filesize_sum, :bigint
  end
end
