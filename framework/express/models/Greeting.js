// Audax Development Research Notes - 3
// https://github.com/andreadavanzo/adrn-3
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Andrea Davanzo

const sequelize = require('../config/database');

class Greeting {
  static async getMessage() {
    const [result] = await sequelize.query("SELECT 'hello world' AS greeting;");
    return result[0].greeting;
  }
}

module.exports = Greeting;


