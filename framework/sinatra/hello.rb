# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

require 'sinatra'
require 'erb'

set :environment, :production

get '/' do
  @greeting = "hello world"
  erb :index
end
