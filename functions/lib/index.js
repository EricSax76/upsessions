"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ping = void 0;
const functions = require("firebase-functions");
exports.ping = functions.https.onRequest((request, response) => {
    response.send('Solomusicos Functions are alive!');
});
//# sourceMappingURL=index.js.map