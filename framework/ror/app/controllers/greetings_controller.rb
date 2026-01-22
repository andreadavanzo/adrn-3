# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

class GreetingsController < ApplicationController
  def index
    text = Greeting.fetch  # raw SQL method
    render plain: text
  end
end
