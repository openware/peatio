# frozen_string_literal: true

class CreateJobs< ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.string :name, null: false
      t.integer :state, default: 0, null: false
      t.json :data
      t.datetime 'started_at'
      t.datetime 'finished_at'
    end
  end
end
