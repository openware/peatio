class MigrateWithdrawChannelsToCurrency < ActiveRecord::Migration
  def change
    if defined?(Currency) && File.file?('config/withdraw_channels.old.yml')
      add_column :currencies, :withdraw_fee, null: false, default: 0, precision: 7, scale: 6
      (YAML.load_file('config/withdraw_channels.old.yml') || []).each do |channel|
        next unless channel.key?('fee')
        Currency.find_by_code!(channel.fetch('currency')).tap do |ccy|
          ccy.update_columns(withdraw_fee: channel['fee'])
        end
      end
    end
  end
end
