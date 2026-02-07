# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

require 'sinatra'
require 'pg'
require 'erb'

# Database Configuration
DB_CONFIG = {
  host: '192.168.37.131',
  dbname: 'postgres',
  user: 'tester',
  password: 'tester'
}
configure do
  set :reload_templates, true
  set :logging, false # Logging consumes disk I/O energy, turn off for pure ACS test
  # Tilt.default_mapping.clear_pipeline_cache! if defined?(Tilt)
end

helpers do
  def db_query(sql)
    conn = PG.connect(DB_CONFIG)
    result = conn.exec(sql)
    conn.close
    result
  rescue PG::Error => e
    halt 500, "Database Error: #{e.message}"
  end
end

get '/' do
  # Fetch data from DB
  result = db_query("SELECT 'hello world' AS greeting;")
  @greeting = result.first['greeting']

  # Render the 'index.erb' template
  erb :index
end
