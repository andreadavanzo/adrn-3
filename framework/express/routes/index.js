// Audax Development Research Notes - 3
// https://github.com/andreadavanzo/adrn-3
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Andrea Davanzo

const express = require('express');
const router = express.Router();
const Greeting = require('../models/Greeting');

router.get('/', async (req, res) => {
  try {
    const greeting = await Greeting.getMessage();
    res.render('index', { greeting: greeting?.message || 'Hello World' });
  } catch (err) {
    res.status(500).send('DB error: ' + err.message);
  }
});

module.exports = router;
