class AddColsToDistpatch < ActiveRecord::Migration
  def change
    add_reference :distpatches, :agency, index: true
    add_column :distpatches, :responder_id, :string, limit: 14, null: false
    add_index :distpatches, :responder_id, unique: true
  end
end
