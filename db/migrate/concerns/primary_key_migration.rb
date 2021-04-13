module PrimaryKeyMigration
  extend ActiveSupport::Concern

  def run_primary_key_migration(mysql_type, postgresql_type, table_names)
    adapter_type = connection.adapter_name.downcase.to_sym
    case adapter_type
    when :mysql, :mysql2
      ActiveRecord::Base.transaction do
        table_names.each do |table_name|
          execute("ALTER TABLE #{table_name} MODIFY COLUMN id #{mysql_type} NOT NULL AUTO_INCREMENT")
        end
      end
    when :postgresql
      ActiveRecord::Base.transaction do
        table_names.each do |table_name|
          execute("ALTER TABLE #{table_name} ALTER COLUMN id SET DATA TYPE #{postgresql_type}")
        end
      end
    else
      raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
    end
  end
end
