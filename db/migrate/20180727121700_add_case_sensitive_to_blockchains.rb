class AddCaseSensitiveToBlockchains < ActiveRecord::Migration
  def change
    add_column :blockchains, :case_sensitive, :boolean, default: true, after: :height
  end
end
