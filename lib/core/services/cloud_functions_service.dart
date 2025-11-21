import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionsService {
  CloudFunctionsService({FirebaseFunctions? functions}) : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<void> notifyChatMessage({required String threadId, required String sender, required String body}) async {
    try {
      final callable = _functions.httpsCallable('sendChatNotification');
      await callable.call({
        'threadId': threadId,
        'sender': sender,
        'body': body,
      });
    } catch (_) {
      // Los entornos locales pueden no tener la función desplegada aún; ignoramos errores suaves.
    }
  }
}
