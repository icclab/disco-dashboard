class CreateInfrastructures < ActiveRecord::Migration[5.0]
  def change
    create_table :infrastructures do |t|
      t.string :name
      t.string :username
      t.string :auth_url
      t.string :tenant

      t.timestamps
    end
  end
end
