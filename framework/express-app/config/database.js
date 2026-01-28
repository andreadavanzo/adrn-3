// Audax Development Research Notes - 3
// https://github.com/andreadavanzo/adrn-3
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Andrea Davanzo

const { Sequelize } = require('sequelize');

const sequelize = new Sequelize('postgres', 'tester', 'tester', {
  host: '192.168.37.131',
  dialect: 'postgres',
  logging: false,
});

module.exports = sequelize;
