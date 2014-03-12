require 'sinatra'
require 'customerio'
require 'time'
require 'logger'

require_relative 'settings'
require_relative 'json-params'

$customerio = Customerio::Client.new(Settings.customerio.site_id, Settings.customerio.api_key)

class CustomerIoPublisher < Sinatra::Base

  register Sinatra::JsonBodyParams

  post '/' do
    event_name = params['event']
    current = params['current']
    previous = params['previous']

    $logger.info "Publishing event #{event_name}"

    $logger.info params.to_json

    if event_name == 'added.person'

      $logger.info 'added.person'

      hash = {
          id: current['id'],
          owner_id: current['owner_id'],
          name: current['name'],
          email: (current['email'].first['value'] rescue nil),
          created_at: Time.parse(current['add_time']).to_i,
      }

      $logger.info hash.to_json

      $customerio.identify(hash)

    end

    if event_name == 'added.deal'

      $logger.info 'added.deal'

      $customerio.track(current['person_id'], 'Deal created', created_at: Time.parse(current['add_time']).to_i)
    end

    if event_name == 'updated.deal'

      if current['stage_id'] != previous['stage_id']

        $logger.info 'Stage update'

        $customerio.track(current['person_id'], "Deal moved to stage #{current['stage']}", created_at: Time.parse(current['add_time']).to_i)
      end

    end
    #if event_name == 'added.deal'
    #
    #  $logger.info 'added.deal'
    #
    #  $customerio.track(current['org_id'], 'Deal Added', {
    #      created_at: Time.parse(current['add_time']).to_i,
    #      stage: current['stage_id'],
    #      status: current['status'],
    #      org: current['org_name'],
    #      person: current['person_name'],
    #      value: current['weighted_value']
    #  })
    #end
    #
    #if event_name == 'updated.deal'
    #
    #  $logger.info 'updated.deal'
    #
    #  $customerio.track(current['org_id'], 'Deal updated', {
    #      created_at: Time.parse(current['add_time']).to_i,
    #      stage: current['stage_id'],
    #      status: current['status'],
    #      org: current['org_name'],
    #      person: current['person_name'],
    #      value: current['weighted_value'],
    #      won_time: (Time.parse(current['won_time']).to_i rescue nil),
    #  })
    #end
    #
    #if event_name == 'added.activity'
    #
    #  $logger.info 'added.activity'
    #
    #  $customerio.track(current['org_id'], 'Deal Added', {
    #      created_at: Time.parse(current['add_time']).to_i,
    #      type: current['type'],
    #      org: current['org_name'],
    #      person: current['person_name'],
    #      is_done: current['done']
    #  })
    #end
    #
    #if event_name == 'updated.activity'
    #
    #  $logger.info 'updated.activity'
    #
    #  $customerio.track(current['org_id'], 'Deal Added', {
    #      type: current['type'],
    #      org: current['org_name'],
    #      person: current['person_name'],
    #      is_done: current['done']
    #  })
    #end

    'OK'
  end
end

