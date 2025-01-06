class AddStarredToNotes < ActiveRecord::Migration[7.0]
  def change
    add_column :notes, :starred, :boolean, default: false
  end
end 