import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> createOrder(String meetingId, int amount) async {
  final res = await http.post(
    Uri.parse(
      "https://us-central1-nyayaconnect-free.cloudfunctions.net/createPaymentOrder",
    ),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'meetingId': meetingId,
      'amount': amount,
    }),
  );

  if (res.statusCode != 200) {
    throw Exception("Order creation failed");
  }

  return jsonDecode(res.body);
}
