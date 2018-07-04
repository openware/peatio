# encoding: UTF-8
# frozen_string_literal: true

describe Services::Archive do
  subject {Services::Archive.new.call}

  let(:orders_table) {"orders_#{(Date.today - 1.day).strftime('%B_%Y')}".downcase}
  let(:trades_table) {"trades_#{(Date.today - 1.day).strftime('%B_%Y')}".downcase}

  context 'should create new tables' do
    it {is_expected.to be_truthy}
  end

  context 'check if table already exists' do

    after do
      ActiveRecord::Base.connection.execute("drop table #{orders_table} ") if ActiveRecord::Base.connection.execute("show tables like '#{orders_table}'").first.present?
      ActiveRecord::Base.connection.execute("drop table #{trades_table} ") if ActiveRecord::Base.connection.execute("show tables like '#{trades_table}'").first.present?
    end

    it {is_expected.to be_falsey}

  end
end