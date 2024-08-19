import 'package:firebase_database/firebase_database.dart';

class OrderService {
  static void updateOrderStatus(Map<String, dynamic> order, String status) {
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref('payments');
    databaseReference.once().then((DatabaseEvent event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        for (var child in snapshot.children) {
          final orderData = Map<String, dynamic>.from(
              (child.value as Map<dynamic, dynamic>)
                  .map((key, value) => MapEntry(key.toString(), value)));
          if (orderData['paymentData']['reference'] ==
              order['paymentData']['reference']) {
            final DatabaseReference orderReference = child.ref;
            orderReference.update({'orderStatus': status});
            break;
          }
        }
      }
    });
  }
}
