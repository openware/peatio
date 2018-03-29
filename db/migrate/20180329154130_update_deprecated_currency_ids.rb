class UpdateDeprecatedCurrencyIds < ActiveRecord::Migration
  def change
    # Migrate deprecated market codes to new.
    if File.file?('config/markets.old.yml')
      (YAML.load_file('config/markets.old.yml') || []).each do |market|
        execute %{UPDATE orders SET currency = '#{market.fetch('id')}' WHERE currency = '#{market.fetch('code')}'}
      end
    end
  end
end
