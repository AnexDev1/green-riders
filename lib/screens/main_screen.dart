import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../widgets/OrderList.dart';
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
  bool _isLoading = true;

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
          if (orderData['orderStatus'] == 'pending') {
            orders.add(orderData);
          }
        }
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      } else {
        setState(() {
          _orders = [];
          _isLoading = false;
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
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : OrderList(orders: _orders),
        ],
      ),
    );
  }
}
