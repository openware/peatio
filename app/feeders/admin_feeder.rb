class AdminFeeder < MemberFeeder
  def feed
    admin_member = FactoryBot.create(:member, :admin)
  end
end
