class AddAddressToDistpatch < ActiveRecord::Migration
  def change
    add_column :distpatches, :address, :string
  end
end
