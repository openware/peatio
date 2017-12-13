class MemberFeeder < AbstractFeeder
  def feed
    password = Faker::Internet.password(10, 20)
    email = Faker::Internet.email

    identity = Identity.find_or_create_by(email: email)
    identity.password = password
    identity.password_confirmation = password
    identity.is_active = true
    identity.save!

    member = Member.find_or_create_by(email: email)
    member.authentications.build(provider: 'identity', uid: identity.id)
    member.save!
    member.active!

    member.id_document.update!(
      name: Faker::Name.name,
      address: Faker::Address.street_address,
      city: Faker::Address.city,
      country: Faker::Address.country,
      zipcode: Faker::Address.zip,
      id_document_type: :id_card,
      id_document_number: Faker::Number.number(15)
    )

    member.id_document.approve!
    end
  end
