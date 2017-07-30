require 'rubygems'
require 'bundler'
require 'json'

Bundler.require

require 'active_record'
require './app/models/speed_stat'

# Change the following to reflect your database settings
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/database.sql'
)
