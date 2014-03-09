require 'sinatra'
require 'google_drive'
require 'pipedrive-ruby'

require_relative 'settings'
require_relative 'pipedrive-api-extra'

class MissionCritical < Sinatra::Base
  post '/mission-critical' do

    $logger.info params

    Pipedrive.authenticate(Settings.pipedrive.api_key)

    user = Pipedrive::User.all.select { |x| x.name.downcase == params['Agent'].downcase }.first

    owner_id = user.id
    org_hash = {
        name: params['Business Name'],
        address: params['Address'],
        :'61bc81655cd1bcce11ce5dbb975b1ae97d2bd8f4' => params['City'],
        bc52a58adb321f5cb1f77c41da2e1d9c43ddd99c: params['State'],
        c83512579d13c7b1a751b068e0133c76d068ea8e: params['Zip Code'],
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
        user_id: 175983, #cody
        value: 0,
        :'081669c9b2a9f8b3d3f8a9ec5a6a4d187ef0c635' => params['Listing URL'],
        :'03dfc0cf0d5dd31c54558f7f3435c3f3eeae3067' => params['Notes/Comments'],
        stage_id: 38,
    }

    deal_1 = Pipedrive::Deal.create deal_hash


    activities = [{
                      key: 'manage-listing',
                      name: 'Listing Construction'
                  }, {
                      key: 'build-listing',
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
                  }, {
                      key: 'pay-commission',
                      name: 'Pay Commission'
                  }, {
                      key: 'yahoo-pin-send',
                      name: 'Yahoo PIN Send'
                  }, {
                      key: 'bing-pin-send',
                      name: 'Bing PIN Send'
                  }, {
                      key: 'yahoo-pin',
                      name: 'Yahoo PIN Activation'
                  }, {
                      key: 'bing-pin',
                      name: 'Bing PIN Activation'
                  }]


    %w{manage-listing build-listing google-pin upsell-call enrollment-interview google-pin-send}.each { |x|

      activity = activities.select { |p| p[:key] == x }.first
      Pipedrive::Activity.good_create({
                                          type: activity[:key],
                                          subject: activity[:name]+ ' - ' + params['Business Name'],
                                          org_id: org_id,
                                          user_id: 176396,
                                          person_id: person.id,
                                          deal_id: deal_1.id
                                      })
    }

    if params['Product'] == 'GYB'

      %w{yahoo-pin-send bing-pin-send yahoo-pin bing-pin}.each { |x|

        activity = activities.select { |p| p[:key] == x }.first

        Pipedrive::Activity.good_create({
                                            type: activity[:key],
                                            subject: activity[:name]+ ' - ' + params['Business Name'],
                                            org_id: org_id,
                                            user_id: 176396,
                                            person_id: person.id,
                                            deal_id: deal_1.id
                                        })
      }
    end

    deal_hash = {
        title: params['Business Name'] + ' ' + params['Product'],
        org_id: org_id,
        person_id: person.id,
        user_id: owner_id,
        value: params['Price'].to_i,
        stage_id: 6,
        status: 'won',
        :'081669c9b2a9f8b3d3f8a9ec5a6a4d187ef0c635' => params['Listing URL'],
        :'03dfc0cf0d5dd31c54558f7f3435c3f3eeae3067' => params['Notes/Comments'],
        :'3d1b58cafdc6a8b9e9d12ba89cd15dc68aa5cfa8' => params['']
    }

    deal_2 = Pipedrive::Deal.create deal_hash

    Pipedrive::Activity.good_create({
                                        type: 'pay-commission',
                                        subject: 'Pay Commission - ' + params['Business Name'],
                                        org_id: org_id,
                                        user_id: 175971,
                                        person_id: person.id,
                                        deal_id: deal_2.id
                                    })


    'OK'

  end
end