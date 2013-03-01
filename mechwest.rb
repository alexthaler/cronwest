require 'sinatra'
require_relative 'mechdriver'

get '/test' do
  MechDriver.new.fire_request
end