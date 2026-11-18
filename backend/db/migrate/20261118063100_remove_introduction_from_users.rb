class RemoveIntroductionFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :introduction, :string
  end
end
