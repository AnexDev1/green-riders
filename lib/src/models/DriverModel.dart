import 'package:firebase_database/firebase_database.dart';

class Driver {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String vehicleType;
  final String licensePlate;
  final double latitude;
  final double longitude;
  final String status;
  final String profilePictureUrl;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.vehicleType,
    required this.licensePlate,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.profilePictureUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'vehicleType': vehicleType,
      'licensePlate': licensePlate,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}

void saveDriverProfile(Driver driver) {
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref('drivers/${driver.id}');
  databaseReference.set(driver.toJson());
}
