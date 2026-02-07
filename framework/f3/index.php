<?php
#
# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

require 'vendor/autoload.php';  // load F3 via Composer


// Start session
session_start();

$f3 = \Base::instance();
$f3->set('DEBUG', 0);
$f3->set('CACHE', false);

// PostgreSQL connection settings
$dbhost = '192.168.37.131';
$dbname = 'postgres';
$dbuser = 'tester';
$dbpass = 'tester';
$dsn = "pgsql:host=$dbhost;dbname=$dbname";

// Route
$f3->route('GET /', function($f3) use ($dsn, $dbuser, $dbpass) {
  try {
    // Connect to PostgreSQL
    $pdo = new PDO($dsn, $dbuser, $dbpass, [
      PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    // Execute query
    $stmt = $pdo->query("SELECT 'Hello World' AS greeting;");
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $greeting = $row['greeting'] ?? 'error';

    // Set variable for template
    $f3->set('greeting', $greeting);

    // Render template
    echo \Template::instance()->render('template.html');

  } catch (PDOException $e) {
    echo "DB connection failed: " . $e->getMessage();
  }
});

$f3->run();