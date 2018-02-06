class RefactorAccountVersions < ActiveRecord::Migration
  def change
    remove_column :account_versions, :currency, :integer
    add_column :account_versions, :currency_id, :integer, unsigned: true
  end
end
