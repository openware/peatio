class DropTwoFactors < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.data_source_exists? 'two_factors'
      drop_table :two_factors
    end
  end
end
