<?php
#
# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class Greeting extends Model
{
  /**
   * Execute the hello world SQL query
   */
  public static function fetch(): string
  {
    $row = DB::selectOne("SELECT 'hello world' AS greeting;");
    return $row->greeting ?? 'error';
  }
}
