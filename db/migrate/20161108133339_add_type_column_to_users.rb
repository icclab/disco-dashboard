class AddTypeColumnToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :usertype, :integer
  end
end
