require 'sinatra'
require 'customerio'
require 'time'

require_relative 'settings'

$customerio = Customerio::Client.new(Settings.customerio.site_id, Settings.customerio.api_key)

class CustomerIoPublisher < Sinatra::Base
  get '/' do
    event_name = params['event']
    current = params['current']

    if event_name == 'added.organization'
      $customerio.identify(
          id: current['id'],
          owner_id: current['owner_id'],
          name: current['name'],
          created_at: Time.parse(current['add_time']),
      )
    end

    if event_name == 'added.deal'

      $customerio.track(current['org_id'], 'Deal Added', {
          created_at: Time.parse(current['add_time']),
          stage: current['stage_id'],
          status: current['status'],
          org: current['org_name'],
          person: current['person_name'],
          value: current['weighted_value']
      })
    end

    if event_name == 'updated.deal'
      $customerio.track(current['org_id'], 'Deal updated', {
          created_at: Time.parse(current['add_time']),
          stage: current['stage_id'],
          status: current['status'],
          org: current['org_name'],
          person: current['person_name'],
          value: current['weighted_value'],
          won_time: (Time.parse(current['won_time']) rescue nil),
      })
    end

    if event_name == 'added.activity'

      $customerio.track(current['org_id'], 'Deal Added', {
          created_at: Time.parse(current['add_time']),
          type: current['type'],
          org: current['org_name'],
          person: current['person_name'],
          is_done: current['done']
      })
      end

    if event_name == 'updated.activity'

      $customerio.track(current['org_id'], 'Deal Added', {
          type: current['type'],
          org: current['org_name'],
          person: current['person_name'],
          is_done: current['done']
      })
    end

    'OK'
  end
end

