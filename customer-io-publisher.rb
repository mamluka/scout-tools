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
          created_at: Time.parse(current['add_time']).utc.to_i,
      }

      $logger.info hash.to_json

      $customerio.identify(hash)

    end

    if event_name == 'added.deal'

      $logger.info 'added.deal'

      $customerio.track(current['person_id'], "Deal created at stage #{current['stage_id']}", created_at: Time.parse(current['add_time']).utc.to_i, value: current['weighted_value'])
    end

    if event_name == 'updated.deal'

      if current['stage_id'] != previous['stage_id']

        $logger.info 'Stage update'

        $customerio.track(current['person_id'], "Deal moved to stage #{current['stage_id']}", updated_at: Time.parse(current['update_time']).utc.to_i, value: current['weighted_value'])
      end

      if current['status'] != previous['status'] && current['status'] == 'won'
        $logger.info 'Deal won'

        $customerio.track(current['person_id'], "Deal won at stage #{current['stage_id']}", updated_at: Time.parse(current['update_time']).utc.to_i)
      end

    end

    if event_name == 'updated.activity'

      $logger.info 'Activity donw'

      if current['done'] != previous['done']
        $customerio.track(current['person_id'], "Activity #{current['type']} done", done_at: Time.parse(current['marked_as_done_time']).utc.to_i)
      end
    end

    'OK'
  end
end

