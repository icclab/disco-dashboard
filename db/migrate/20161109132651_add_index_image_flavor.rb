class AddIndexImageFlavor < ActiveRecord::Migration[5.0]
  def change
    add_index :images, :img_id, unique: true
    add_index :flavors, :fl_id, unique: true
  end
end
