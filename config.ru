require 'sinatra'
require './src/cron_west'

run CronWest.new
