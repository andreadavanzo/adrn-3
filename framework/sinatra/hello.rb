# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

require 'sinatra'
require 'pg'

# PostgreSQL connection settings
DB_HOST = '192.168.37.131'
DB_NAME = 'postgres'
DB_USER = 'tester'
DB_PASS = 'tester'

get '/' do
  content_type 'text/plain'

  begin
    conn = PG.connect(host: DB_HOST, dbname: DB_NAME, user: DB_USER, password: DB_PASS)
    result = conn.exec("SELECT 'hello world' AS greeting;")
    row = result.first
    row['greeting'] || 'error'
  rescue PG::Error => e
    "DB connection failed: #{e.message}"
  ensure
    conn&.close
  end
end
