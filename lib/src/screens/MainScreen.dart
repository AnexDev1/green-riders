import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../widgets/OverView.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('payments');
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _listenToOrders();
  }

  void _listenToOrders() {
    _databaseReference.onValue.listen((DatabaseEvent event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        final orders = <Map<String, dynamic>>[];
        for (var child in snapshot.children) {
          final orderData = Map<String, dynamic>.from(
              (child.value as Map<dynamic, dynamic>)
                  .map((key, value) => MapEntry(key.toString(), value)));
          if (orderData['orderStatus'] == 'delivered') {
            orders.add(orderData);
          }
        }
        setState(() {
          _orders = orders;
        });
        print(_orders);
      } else {
        setState(() {
          _orders = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: Column(
        children: [
          const Overview(),
          Expanded(
            child: _orders.isEmpty
                ? const Center(child: Text('No orders found'))
                : ListView.builder(
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final paymentData =
                          order['paymentData'] as Map<dynamic, dynamic>;
                      return ListTile(
                        title: Text('Order ID: ${paymentData['reference']}'),
                        subtitle: Text(
                            'User: ${paymentData['first_name']} - Amount: ${paymentData['amount']} Birr'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
