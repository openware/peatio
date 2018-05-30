# frozen_string_literal: true

class ChangeMembersLevelType < ActiveRecord::Migration
  def change
    add_column :members, :level_int, :integer, null: false, default: 0
    update_level_int
    remove_column :members, :level
    rename_column :members, :level_int, :level
  end

  private

  def update_level_int
    Member.find_each do |m|
      m.update_column(:level_int, to_numerical_barong_level(m.level))
    end
  end

  def to_numerical_barong_level(level)
    case level.to_sym
    when :email_verified then 1
    when :phone_verified then 2
    when :identity_verified then 3
    else 0
    end
  end
end
