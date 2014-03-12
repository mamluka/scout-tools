require './formstack-pipedrive-mc'
require './formstack-pipedrive-plans'
require './formstack-pipedrive-orders'
require './ytel-bridge'
require './customer-io-publisher'

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

map '/ytel' do
  run YTel
end

map '/publisher' do
  run CustomerIoPublisher
end