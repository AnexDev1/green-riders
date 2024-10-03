import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../services/order_service.dart';
import 'customer_location.dart';

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
  List<LatLng> _riderLocations = [];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.countdownSeconds;
    _startTimer();
    _fetchRiderLocations();
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchRiderLocations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DatabaseReference ref = FirebaseDatabase.instance.ref('drivers');
      final DataSnapshot snapshot = await ref.get();
      final Map<dynamic, dynamic> data =
          snapshot.value as Map<dynamic, dynamic>;

      setState(() {
        _riderLocations = data.values
            .where((driver) => driver['email'] == user.email)
            .map((driver) {
          return LatLng(driver['latitude'], driver['longitude']);
        }).toList();
      });
    }
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
                OrderService.updateOrderStatus(widget.order, 'picked up');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => CustomerLocation(
                      userLocation: LatLng(
                        widget.order['location']['latitude'],
                        widget.order['location']['longitude'],
                      ),
                      riderLocations: _riderLocations, order:widget.order,
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
