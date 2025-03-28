import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as dartCoverter;

class LocationModel {
  final double latitude;
  final double longitude;
  final double? heading;
  final DateTime timestamp;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.heading,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      heading: json['heading']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}

class LocationTrackingService {

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Stream<LocationModel> getLocationUpdates(String orderId) {
    print('location from firebase:');

    return _database.ref().child('delivery_locations').child(orderId).onValue.map((event) {
      if (event.snapshot.value == null) {
        throw Exception('No location data available');
      }
      print('location from firebase: ${event.snapshot.value}');
      return LocationModel.fromJson(Map<String, dynamic>.from(event.snapshot.value as Map));
    });
  }
}
