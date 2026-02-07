<?php
#
# Audax Development Research Notes - 2
# https://github.com/andreadavanzo/adrn-2
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo
#
# Stats script for log data analysis

if ($argc < 3) {
  die("Usage: php stats.php <file.csv> <target_column> [tag_column] [decimal]\n");
}

$filename = $argv[1];
$target_col = $argv[2];
$tag_col_name = $argv[3] ?? 'tag';
$decimal = $argv[4] ?? 6;

if (!file_exists($filename)) {
  die("Error: File '$filename' not found.\n");
}

$handle = fopen($filename, "r");
$header = fgetcsv($handle);

// Find indices for both the data column and the tag column
$col_index = is_numeric($target_col)
  ? (int)$target_col
  : array_search($target_col, $header);

$tag_index = array_search($tag_col_name, $header);

if ($col_index === false || $tag_index === false) {
  die("Error: Column '$target_col' or '$tag_col_name' not found.\n");
}

$stats = [];

while (($data = fgetcsv($handle)) !== false) {
  if (
    isset($data[$col_index]) &&
    isset($data[$tag_index]) &&
    is_numeric($data[$col_index])
  ) {
    $val = (float)$data[$col_index];
    $tag = $data[$tag_index];

    if (!isset($stats[$tag])) {
      $stats[$tag] = [
        'min' => $val,
        'max' => $val,
        'sum' => 0,
        'count' => 0
      ];
    }

    if ($val < $stats[$tag]['min']) {
      $stats[$tag]['min'] = $val;
    }

    if ($val > $stats[$tag]['max']) {
      $stats[$tag]['max'] = $val;
    }

    $stats[$tag]['sum'] += $val;
    $stats[$tag]['count']++;
  }
}

fclose($handle);

echo str_pad("TAG", 15) . " | " .
     str_pad("COUNT", 8) . " | " .
     str_pad("MIN", 10) . " | " .
     str_pad("AVG", 10) . " | " .
     str_pad("MAX", 10) . "\n";

echo str_repeat("-", 65) . "\n";

foreach ($stats as $tag => $data) {
  $avg = $data['sum'] / $data['count'];

  echo str_pad($tag, 15) . " | " .
       str_pad($data['count'], 8) . " | " .
       str_pad(number_format($data['min'], $decimal, '.', ''), 10) . " | " .
       str_pad(number_format($avg, $decimal, '.', ''), 10) . " | " .
       str_pad(number_format($data['max'], $decimal, '.', ''), 10) . "\n";
}
