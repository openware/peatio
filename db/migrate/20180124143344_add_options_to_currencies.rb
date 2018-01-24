class AddOptionsToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :options, :json

    reversible do |dir|
      dir.up do
        execute <<-SQL
          update currencies set options = "{}"
        SQL
      end
      dir.down do
        execute <<-SQL
          update currencies set options = null
        SQL
      end
    end
  end
end
