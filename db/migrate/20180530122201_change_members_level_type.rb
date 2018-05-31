# frozen_string_literal: true

class ChangeMembersLevelType < ActiveRecord::Migration
  class Member < ActiveRecord::Base; end

  def change
    reversible do |direction|
      direction.up do
        add_column :members, :level_int, :integer, null: false, default: 0
        update_to_integer_barong_level
        remove_column :members, :level
        rename_column :members, :level_int, :level
      end
      direction.down do
        add_column :members, :level_str, :string, null: false, default: ''
        update_to_string_barong_level
        remove_column :members, :level
        rename_column :members, :level_str, :level
      end
    end
  end

  private

  def update_to_integer_barong_level
    Member.find_each do |m|
      m.update_column(:level_int, to_integer_barong_level(m.level))
    end
  end

  def to_integer_barong_level(level)
    case level.to_sym
    when :email_verified then 1
    when :phone_verified then 2
    when :identity_verified then 3
    else 0
    end
  end

  def update_to_string_barong_level
    Member.find_each do |m|
      m.update_column(:level_str, to_string_barong_level(m.level))
    end
  end

  def to_string_barong_level(level)
    case level
    when 1 then :email_verified
    when 2 then :phone_verified
    when 3 then :identity_verified
    else :unverified
    end
  end
end
