class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string, null: false
    add_reference :users, :prefecture, null: false, foreign_key: true
    add_column :users, :introduction, :string
  end
end
