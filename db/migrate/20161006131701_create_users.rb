class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.string :auth_url
      t.string :tenant
      t.string :disco_ip

      t.timestamps
    end
  end
end
