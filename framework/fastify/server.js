// Audax Development Research Notes - 3
// https://github.com/andreadavanzo/adrn-3
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Andrea Davanzo

const fastify = require('fastify')({ logger: true });
const path = require('path'); // Added this
const { getGreetingHandler } = require('./controllers/greetingController');

// 1. Register the view engine here
fastify.register(require('@fastify/view'), {
  engine: {
    ejs: require('ejs'),
  },
  root: path.join(__dirname, 'views'),
});

// 2. Keep the route as '/' (Nginx handles the prefix)
fastify.get('/', getGreetingHandler);

const start = async () => {
  try {
    await fastify.listen({ port: 3000, host: '0.0.0.0' });
    console.log('Server running at http://localhost:3000');
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};

start();