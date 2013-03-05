require 'sinatra'
require './src/cron_west'

root = ::File.dirname(__FILE__)
public_folder = 'src/public'

run CronWest.new
