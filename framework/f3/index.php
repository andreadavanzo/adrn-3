<?php
#
# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

require 'vendor/autoload.php';  // load F3 via Composer

$f3 = \Base::instance();

// PostgreSQL connection settings
$dbhost = '192.168.37.131';
$dbname = 'postgres';
$dbuser = 'tester';
$dbpass = 'tester';
$dsn = "pgsql:host=$dbhost;dbname=$dbname";

$f3->route('GET /', function($f3) use ($dsn, $dbuser, $dbpass) {
  header('Content-Type: text/plain');

  // try {
    $pdo = new PDO($dsn, $dbuser, $dbpass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    $stmt = $pdo->query("SELECT 'hello world' AS greeting;");
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    echo $row['greeting'] ?? 'error';

  // } catch (PDOException $e) {
  //   echo "DB connection failed: " . $e->getMessage();
  // }
});

$f3->run();
