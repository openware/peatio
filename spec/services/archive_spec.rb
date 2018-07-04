# encoding: UTF-8
# frozen_string_literal: true

describe Services::Archive do
  subject {Services::Archive.new.call}

  let(:orders_table) {"orders_#{(Date.today - 1.day).strftime('%B_%Y')}".downcase}
  let(:trades_table) {"trades_#{(Date.today - 1.day).strftime('%B_%Y')}".downcase}

  after(:each) do
    drop_archive_tables
  end

  context 'should create new tables' do
    before do
      drop_archive_tables
    end

    it {is_expected.to be_truthy}
  end

  context 'check if table already exists' do
    let(:date_start) {(Date.today - 1.day).beginning_of_month}
    let(:date_end) {(Date.today - 1.day).end_of_month}
    let(:order_sql) {"CREATE TABLE #{orders_table} AS (SELECT * FROM orders WHERE DATE(created_at) BETWEEN '#{date_start}' AND '#{date_end}') ;"}
    let(:trades_sql) {"CREATE TABLE #{trades_table} AS (SELECT * FROM trades WHERE DATE(created_at) BETWEEN '#{date_start}' AND '#{date_end}') ;"}

    before do
      create_archive_tables
    end

    it {is_expected.to be_falsey}
  end
end
