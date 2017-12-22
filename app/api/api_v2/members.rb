module APIv2
  class Members < Grape::API
    helpers APIv2::NamedParams

    before { authenticate! }

    before do
      current_user.accounts.each do |acc|
        next unless acc.currency_obj.coin?
        (acc.payment_address || acc.payment_addresses.create!(currency: acc.currency)).tap do |addr|
          addr.gen_address if addr.address.blank?
        end
      end
    end

    desc 'Get your profile and accounts info.', scopes: %w[ profile ]
    get '/members/me' do
      present current_user, with: APIv2::Entities::Member
    end
  end
end
