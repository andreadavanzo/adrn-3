// Audax Development Research Notes - 3
// https://github.com/andreadavanzo/adrn-3
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Andrea Davanzo

const express = require('express');
const router = express.Router();

// Synchronous route handler for baseline research
router.get('/', (req, res) => {
  // Hardcoded to eliminate DB I/O and latency
  const greeting = 'hello world';

  res.render('index', { greeting: greeting });
});

module.exports = router;
