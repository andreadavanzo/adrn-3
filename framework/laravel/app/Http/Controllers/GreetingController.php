<?php
#
# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Greeting;
use Illuminate\Http\Response as HttpResponse;

class GreetingController extends Controller
{
  public function index(): HttpResponse
  {
    $text = Greeting::fetch();

    return response($text, 200)->header('Content-Type', 'text/plain');
  }
}
