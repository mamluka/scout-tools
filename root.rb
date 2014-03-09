require 'rack'
require 'logger'

require_relative 'formstack-pipedrive-mc'
require_relative 'formstack-pipedrive-orders'
require_relative 'formstack-pipedrive-plans'

$logger = Logger.new('log.log')

run MissionCritical
#run Orders
#run Plans