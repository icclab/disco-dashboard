class AddGroupReferenceTask < ActiveRecord::Migration[5.0]
  def change
    add_reference :tasks, :group, index: true
  end
end
