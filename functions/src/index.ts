import * as functions from 'firebase-functions';

export const ping = functions.https.onRequest(
  (request: functions.https.Request, response: functions.Response) => {
    response.send('Solomusicos Functions are alive!');
  },
);
