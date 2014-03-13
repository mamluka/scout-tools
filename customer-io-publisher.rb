require 'sinatra'
require 'customerio'
require 'time'
require 'logger'
require 'pipedrive-ruby'

require_relative 'settings'
require_relative 'json-params'

$customerio = Customerio::Client.new(Settings.customerio.site_id, Settings.customerio.api_key)
$pipedrive = Pipedrive.authenticate(Settings.pipedrive.api_key)

$marketing_tags = [
    {
        id: 36,
        label: "Google.plus"
    },
    {
        id: 37,
        label: "Yahoo"
    },
    {
        id: 38,
        label: "Bing"
    },
    {
        id: 39,
        label: "Website"
    },
    {
        id: 40,
        label: "Mobile Conversion"
    },
    {
        id: 41,
        label: "Connect"
    },
    {
        id: 42,
        label: "Identity"
    },
    {
        id: 43,
        label: "PPC"
    },
    {
        id: 44,
        label: "Social Media"
    }
]

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

      next if not current['org_id']

      org = Pipedrive::Organization.find(current['org_id'])

      $logger.info 'Org info'
      $logger.info org

      marketing_tag_ids = org[:'8518f3400b50d0480301baf80ba187197e6ef811']

      hash = {
          id: current['id'],
          owner_id: current['owner_id'],
          name: current['name'],
          email: (current['email'].first['value'] rescue nil),
          phone: (current['phone'].first['value'] rescue nil),
          address: org.address,
          address2: org[:d6ba35d4c75af8ff28ab3c114ea47116b77db469],
          city: org[:'61bc81655cd1bcce11ce5dbb975b1ae97d2bd8f4'],
          state: org[:bc52a58adb321f5cb1f77c41da2e1d9c43ddd99c],
          zip: org[:c83512579d13c7b1a751b068e0133c76d068ea8e],
          website: [:'69bdbbe9f2e88f17ca4caf0532d61833aa086956'],
          business_description: org[:'8d71387e1817b07ad4092cde9ae69c92c97c1782'],
          keywords: org[:f09b1af3dde76c4c8c3acd76cc9bfb0366a3a116],
          marketing_tags: $marketing_tags.select { |x| marketing_tag_ids.include?(x[:id]) }.map { |x| x[:label] },
          listing_url: org['5aca120ee2df77e91dbbb435e9784322da79cb8e'],
          created_at: Time.parse(current['add_time']).utc.to_i,
      }

      $logger.info hash.to_json

      $customerio.identify(hash)

    end

    if event_name == 'added.deal'

      $logger.info 'added.deal'

      org_hash =

          $customerio.track(current['person_id'], "Deal created at stage #{current['stage_id']}",
                            created_at: Time.parse(current['add_time']).utc.to_i,
                            value: current['weighted_value'],

          )
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

