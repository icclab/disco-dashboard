class CreateAssignments < ActiveRecord::Migration[5.0]
  def change
    create_table :assignments do |t|
      t.belongs_to :group, index: true
      t.belongs_to :cluster, index: true
      t.timestamps
    end
  end
end
