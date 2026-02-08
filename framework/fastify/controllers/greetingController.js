// Audax Development Research Notes - 3
// https://github.com/andreadavanzo/adrn-3
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Andrea Davanzo

function getGreetingHandler(request, reply) {
    const message = 'hello world';
    return reply.view('index.ejs', { greeting: message });
}

module.exports = { getGreetingHandler };
