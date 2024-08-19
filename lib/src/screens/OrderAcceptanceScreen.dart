import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:slide_to_act/slide_to_act.dart';

import 'CustomerLocation.dart';
import 'MainScreen.dart';

class OrderAcceptanceScreen extends StatefulWidget {
  final int countdownSeconds;
  final Map<String, dynamic> order;

  const OrderAcceptanceScreen({
    super.key,
    required this.countdownSeconds,
    required this.order,
  });

  @override
  _OrderAcceptanceScreenState createState() => _OrderAcceptanceScreenState();
}

class _OrderAcceptanceScreenState extends State<OrderAcceptanceScreen> {
  late int _remainingSeconds;
  late Timer _timer;
  bool _orderPickedUp = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.countdownSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        _showTooLateMessage();
      }
    });
  }

  void _showTooLateMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Too Late'),
        content: const Text('Too late to pick the order.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(String status) {
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref('payments');
    databaseReference.once().then((DatabaseEvent event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        for (var child in snapshot.children) {
          final orderData = Map<String, dynamic>.from(
              (child.value as Map<dynamic, dynamic>)
                  .map((key, value) => MapEntry(key.toString(), value)));
          print(orderData);

          if (orderData['paymentData']['reference'] ==
              widget.order['paymentData']['reference']) {
            final DatabaseReference orderReference = child.ref;
            orderReference.update({'orderStatus': status});
            break;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Acceptance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Time remaining: $_remainingSeconds seconds',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 50),
            SlideAction(
              text:
                  _orderPickedUp ? 'Order Picked Up' : 'Slide to Pick Up Order',
              onSubmit: () {
                setState(() {
                  _orderPickedUp = true;
                });
                _updateOrderStatus('picked up');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => CustomerLocation(
                      userLocation: LatLng(
                        widget.order['location']['latitude'],
                        widget.order['location']['longitude'],
                      ),
                      riderLocations: const [
                        LatLng(7.6764406, 36.832514),
                      ],
                    ),
                  ),
                );
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
