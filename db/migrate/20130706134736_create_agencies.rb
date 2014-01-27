class CreateAgencies < ActiveRecord::Migration
  def change
    create_table :agencies do |t|
      t.string :code, limit: 2
      t.string :name, limit: 63

      t.timestamps
    end
  end
end
