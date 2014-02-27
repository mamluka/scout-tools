require 'sinatra'
require 'google_drive'

require_relative 'settings'
require_relative 'formstack-pipedrive-bridge'

set :port, 3000

post '/bridge' do

  Pipedrive.authenticate(Settings.pipedrive.api_key)

  user = Pipedrive::User.all.select { |x| x.name.downcase == params['Agent'].downcase }.first

  owner_id = user.id
  org_hash = {
      name: params['Business Name'],
      address: params['Address'],
      :'61bc81655cd1bcce11ce5dbb975b1ae97d2bd8f4' => params['City'],
      bc52a58adb321f5cb1f77c41da2e1d9c43ddd99c: params['State'],
      c83512579d13c7b1a751b068e0133c76d068ea8e: params['Zip'],
      owner_id: owner_id
  }
  org = Pipedrive::Organization.create(org_hash)
  org_id = org.id

  person_hash = {
      name: params['First Name'] + ' ' + params['Last Name'],
      org_id: org_id,
      phone: params['Phone'],
      owner_id: owner_id

  }

  person = Pipedrive::Person.create person_hash

  deal_hash = {
      title: params['Business Name'] + ' ' + params['Product'],
      org_id: org_id,
      person_id: person.id,
      user_id: owner_id,
      value: params['Price'].to_i,
      #stage: 6,
  }

  deal = Pipedrive::Deal.create deal_hash


  activities = [{
                    key: 'manage-listing',
                    name: 'Listing Construction'
                }, {
                    key: 'manage-listing',
                    name: 'Collect Business Info'
                }, {
                    key: 'google-pin',
                    name: 'Google PIN Activation'
                }, {
                    key: 'upsell-call',
                    name: 'Upsell Appt'
                }, {
                    key: 'enrollment-interview',
                    name: 'Enrollment Interview'
                }, {
                    key: 'google-pin-send',
                    name: 'Google PIN Send'
                }]


  activities.each { |x|
    Pipedrive::Activity.good_create({
                                        type: x[:key],
                                        subject: x[:name]+ '-' + params['Business Name'],
                                        org_id: org_id,
                                        user_id: owner_id,
                                        person_id: person.id,
                                        deal_id: deal.id
                                    })
  }
end
