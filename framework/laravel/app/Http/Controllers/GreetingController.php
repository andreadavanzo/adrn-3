<?php
#
# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\Response as HttpResponse;
use Illuminate\View\View; // Import the View class

class GreetingController extends Controller
{
  public function index(): View
  {
    return view('greetings', ['greeting' => "hello world"]);
  }
}