class CreateKeypairs < ActiveRecord::Migration[5.0]
  def change
    create_table :keypairs do |t|
      t.belongs_to :infrastructure, index: true
      t.string :name
      t.timestamps
    end
  end
end
