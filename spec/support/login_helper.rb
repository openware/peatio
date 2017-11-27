def login(identity, otp: nil, password: nil)
  visit root_path
  click_on I18n.t('header.signin')
  expect(current_path).to eq(signin_path)

  within 'form#new_identity' do
    fill_in 'identity_email', with: identity.email
    fill_in 'identity_password', with: (password || identity.password)
    click_on I18n.t('header.signin')
  end

end

def signout
  click_link I18n.t('header.signout')
end

def check_signin
  expect(page).not_to have_content(I18n.t('header.signin'))
end

alias signin login
