require 'sinatra'
require 'google_drive'
require 'pipedrive-ruby'

require_relative 'settings'
require_relative 'pipedrive-api-extra'

class Orders < Sinatra::Base
  post '/' do

    $logger.info params

    Pipedrive.authenticate(Settings.pipedrive.api_key)

    org_hash = {
        name: params['Business Name'],
        address: params['Address'],
        :'61bc81655cd1bcce11ce5dbb975b1ae97d2bd8f4' => params['City'],
        bc52a58adb321f5cb1f77c41da2e1d9c43ddd99c: params['State'],
        c83512579d13c7b1a751b068e0133c76d068ea8e: params['Zip'],
        :'69bdbbe9f2e88f17ca4caf0532d61833aa086956' => params['Website Address'],
        owner_id: 175756 #jon
    }
    org = Pipedrive::Organization.create(org_hash)
    org_id = org.id

    person_hash = {
        name: params['First Name'] + ' ' + params['Last Name'],
        org_id: org_id,
        phone: params['Phone'],
        email: params['Email'],
        owner_id: 175756

    }

    person = Pipedrive::Person.create person_hash

    deal_hash = {
        title: params['Business Name'] + ' ' + params['Product'],
        org_id: org_id,
        person_id: person.id,
        user_id: 175983, #cody
        value: params['Order Total'].to_i,
        stage_id: 5,
        status: 'won'
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
                  }, {
                      key: 'citations-package-setup',
                      name: 'Citations Package Setup'
                  }, {
                      key: 'citations-report',
                      name: 'Citations Report'
                  }, {
                      key: 'website-build',
                      name: 'Website Build'
                  }, {
                      key: 'add-recurring-price',
                      name: 'Add Recurring Price'
                  }]


    Pipedrive::Activity.good_create({
                                        type: 'pay-commission',
                                        subject: 'Pay commission - ' + params['Business Name'],
                                        org_id: org_id,
                                        user_id: 175756,
                                        person_id: person.id,
                                        deal_id: deal_1.id
                                    })

    Pipedrive::Activity.good_create({
                                        type: 'setup-arb',
                                        subject: 'Setup ARB - ' + params['Business Name'],
                                        org_id: org_id,
                                        user_id: 175971,
                                        person_id: person.id,
                                        deal_id: deal_1.id
                                    })

    Pipedrive::Activity.good_create({
                                        type: 'add-recurring-price',
                                        subject: 'Add Recurring Price - ' + params['Business Name'],
                                        org_id: org_id,
                                        user_id: 175971,
                                        person_id: person.id,
                                        deal_id: deal_1.id
                                    })


    deal_hash = {
        title: params['Business Name'] + ' ' + params['Product'],
        org_id: org_id,
        person_id: person.id,
        user_id: 175983, #cody,
        value: 0,
        :'081669c9b2a9f8b3d3f8a9ec5a6a4d187ef0c635' => params['Website Address'],
        :'03dfc0cf0d5dd31c54558f7f3435c3f3eeae3067' => params['Notes/Comments']
    }

    case params['Product']
      when '999'
        deal_hash[:stage_id] = 23
      when '499'
        deal_hash[:stage_id] = 18
      when '799'
        deal_hash[:stage_id] = 11
      else
        deal_hash[:stage_id] = 23
    end

    deal_2 = Pipedrive::Deal.create deal_hash

    case params['Product']
      when '999' #identity
        deal2_activities= %w(citations-package-setup citations-report website-build)
      when '499' #connect
        deal2_activities= %w(citations-package-setup citations-report)
      when '799' #lead
        deal2_activities= %w(website-build)
      else
        deal2_activities= %w(citations-package-setup citations-report website-build)
    end

    deal2_activities.each { |x|

      activity = activities.select { |p| p[:key] == x }.first

      Pipedrive::Activity.good_create({
                                          type: activity[:key],
                                          subject: activity[:name]+ ' - ' + params['Business Name'],
                                          org_id: org_id,
                                          user_id: 175983,
                                          person_id: person.id,
                                          deal_id: deal_2.id
                                      })
    }

    'OK'

  end
end