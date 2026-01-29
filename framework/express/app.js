// Audax Development Research Notes - 3
// https://github.com/andreadavanzo/adrn-3
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Andrea Davanzo

const express = require('express');
const path = require('path'); // Add this!
const app = express();
const sequelize = require('./config/database');
const indexRouter = require('./routes/index');

// --- VIEW ENGINE SETUP ---
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
// -------------------------

app.use('/', indexRouter);

(async () => {
  try {
    await sequelize.authenticate();
    app.listen(3000, () => {
      console.log('Server running on http://localhost:3000');
    });
  } catch (err) {
    console.error('Unable to connect to the database:', err);
  }
})();
