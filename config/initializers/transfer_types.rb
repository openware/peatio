# frozen_string_literal: true
begin
  types = YAML.load_file("#{Rails.root}/config/transfer_types.yml").symbolize_keys
  Deposit::TRANSFER_TYPES.merge!(types['deposit'])
  Withdraw::TRANSFER_TYPES.merge!(types['withdraw'])
  Deposit.enumerize :transfer_type, in: Deposit::TRANSFER_TYPES
  Deposit.enumerize :transfer_type, in: Withdraw::TRANSFER_TYPES
rescue StandardError => e
  Rails.logger.error { e.message }
end
