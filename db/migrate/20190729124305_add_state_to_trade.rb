class AddStateToTrade < ActiveRecord::Migration[5.2]
  def change
    reversible do |direction|
      direction.up do
        add_column :trades, :state, :integer, null: false, limit: 1, index: true, after: :funds
        execute 'UPDATE trades set trades.state = 1'
      end

      direction.down do
        remove_column :trades, :state
      end
    end
  end
end
