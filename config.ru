require './formstack-pipedrive-mc'
require './formstack-pipedrive-plans'
require './formstack-pipedrive-orders'

require 'logger'
$logger = Logger.new('log.log')

map '/mission-critical' do
  run MissionCritical
end

map '/orders' do
  run Orders
end

map '/plans' do
  run Plans
end