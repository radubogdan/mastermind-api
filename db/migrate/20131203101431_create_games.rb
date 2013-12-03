class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :number
      t.string :game_token
      t.string :name
      t.integer :tries, default: 0

      t.timestamps
    end
  end
end
