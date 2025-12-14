"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.seedChatThreads = exports.ping = void 0;
const functions = require("firebase-functions");
const chatSeeder_1 = require("./chatSeeder");
Object.defineProperty(exports, "seedChatThreads", { enumerable: true, get: function () { return chatSeeder_1.seedChatThreads; } });
exports.ping = functions.https.onRequest((request, response) => {
    response.send('Solomusicos Functions are alive!');
});
//# sourceMappingURL=index.js.map