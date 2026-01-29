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
use Illuminate\View\View; // Import the View class

class GreetingController extends Controller
{
  public function index(): View
  {
    // Fetch the data from your model
    $text = Greeting::fetch();

    // Return the view 'greetings' and pass the variable
    return view('greetings', ['greeting' => $text]);
  }
}