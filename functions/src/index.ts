import * as functions from 'firebase-functions';

export const ping = functions.https.onRequest((request, response) => {
  response.send('Solomusicos Functions are alive!');
});
