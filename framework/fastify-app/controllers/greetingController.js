// Audax Development Research Notes - 3
// https://github.com/andreadavanzo/adrn-3
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Andrea Davanzo

const { getGreeting } = require('../models/greetingModel');

async function getGreetingHandler(request, reply) {
  try {
    const row = await getGreeting();
    reply.type('text/plain').send(row?.greeting || 'error');
  } catch (err) {
    console.error(err);
    reply.status(500).send('DB connection failed');
  }
}

module.exports = { getGreetingHandler };
