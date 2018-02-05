namespace :accounts do
  desc "Add new currency accounts to existing users"
  task touch: :environment do
    Member.find_each(&:touch_accounts)
  end
end
