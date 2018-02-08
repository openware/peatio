module ActiveRecordCurrencible
  extend ActiveSupport::Concern

  included do
    belongs_to :currency
  end
end
