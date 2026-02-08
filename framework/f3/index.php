<?php
#
# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

require 'vendor/autoload.php';  // load F3 via Composer

$f3 = \Base::instance();
$f3->set('DEBUG', 0);
$f3->set('CACHE', true);

// Route
$f3->route('GET /', function($f3) {
  $greeting = 'hello world';

  $f3->set('greeting', $greeting);
  echo \Template::instance()->render('template.html');

});

$f3->run();