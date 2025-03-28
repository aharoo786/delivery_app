import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/order/domain/models/delivery_man_model.dart';
import 'package:flutter_grocery/features/order/domain/models/order_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_grocery/features/order/services/location_tracking_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/models/config_model.dart';
import '../../splash/providers/splash_provider.dart';

class TrackingMapWidget extends StatefulWidget {
  final DeliveryManModel? deliveryManModel;
  final String? orderID;
  final DeliveryAddress? addressModel;
  const TrackingMapWidget({super.key, required this.deliveryManModel, required this.orderID, required this.addressModel});

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  String? _routePolyline;
  Timer? _locationTimer;
  bool _isFirebaseDatafound = true;

  @override
  void initState() {
    super.initState();

    _startLocationUpdates();
    _getDirections();
  }

  Future<void> _getDirections() async {
    if (widget.deliveryManModel == null) return;

    final origin = '${widget.deliveryManModel?.latitude ?? ''},${widget.deliveryManModel?.longitude ?? ''}';
    final destination = '${widget.addressModel?.latitude ?? 0},${widget.addressModel?.longitude ?? 0}';

    print('Origin: $origin');
    print('Destination: $destination');

    String apiKey = 'AIzaSyBNfDDSWLMTtVpDy58bnhhU4x_1jLoJnJA';
    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&mode=driving&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

        if (data['status'] == 'ZERO_RESULTS') {
          print('No route found between the specified locations.');
          return;
        }

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          setState(() {
            _routePolyline = data['routes'][0]['overview_polyline']['points'];
            _updateRoutePolyline();
          });
        } else {
          print('Error: ${data['status']}');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting directions: $e');
    }
  }

  void _updateRoutePolyline() {
    if (_routePolyline != null) {
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: _decodePolyline(_routePolyline!),
            color: Colors.black,
            width: 8,
          ),
        };
      });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latDouble = lat / 1E5;
      double lngDouble = lng / 1E5;
      poly.add(LatLng(latDouble, lngDouble));
    }
    return poly;
  }

  void _startLocationUpdates() {
    if (widget.orderID == null) return;

    LocationTrackingService().getLocationUpdates(widget.orderID ?? '')?.listen((location) {
      if (mounted) {
        setState(() {
          _updateMapWithLocation(location);
        });
      }
      print('location from firebase: ${location}');
    }, onError: (error) {
      setState(() {
        _isFirebaseDatafound = false;
      });
      print("Error getting location updates: $error");
    });
  }

  void _updateMapWithLocation(LocationModel location) async {
    final double deliveryLat = double.tryParse(widget.addressModel?.latitude ?? '') ?? 0;
    final double deliveryLng = double.tryParse(widget.addressModel?.longitude ?? '') ?? 0;

    final LatLng position = LatLng(location.latitude, location.longitude);
    final LatLng deliveryPosition = LatLng(deliveryLat, deliveryLng);

    final BitmapDescriptor deliveryIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)), // Adjust size if needed
      'assets/image/delivery_boy_marker.png',
    );

    final BitmapDescriptor deliveryLocation = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)), // Adjust size if needed
      'assets/image/address_image.png',
    );

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('rider'),
          position: position,
          icon: deliveryIcon,
          rotation: location.heading ?? 0,
          infoWindow: const InfoWindow(title: 'Delivery Partner'),
        ),
        Marker(
          markerId: const MarkerId('delivery'),
          position: deliveryPosition,
          icon: deliveryLocation,
          infoWindow: const InfoWindow(title: 'Delivery Location'),
        ),
      };
    });

    // Calculate appropriate bounds considering the map height (250)
    _mapController?.getVisibleRegion().then((visibleRegion) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          math.min(location.latitude, deliveryLat),
          math.min(location.longitude, deliveryLng),
        ),
        northeast: LatLng(
          math.max(location.latitude, deliveryLat),
          math.max(location.longitude, deliveryLng),
        ),
      );

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel? configModel = Provider.of<SplashProvider>(context, listen: false).configModel;
    return (configModel?.googleMapStatus ?? false)
        ? _isFirebaseDatafound
            ? SizedBox(
                height: 250,
                child: Stack(
                  children: [

                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          double.tryParse(widget.deliveryManModel?.latitude ?? '') ?? double.parse(widget.addressModel?.latitude ?? ''),
                          double.tryParse(widget.deliveryManModel?.longitude ?? '') ?? double.parse(widget.addressModel?.longitude ?? ''),
                        ),
                        zoom: 15,
                      ),
                      onMapCreated: (controller) {
                        setState(() {
                          _mapController = controller;
                        });
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: _markers,
                      polylines: _polylines,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: true,
                      onTap: (latLng) async {
                        if (widget.deliveryManModel?.latitude != null && widget.addressModel != null && widget.addressModel?.latitude != null) {
                          String url = 'https://www.google.com/maps/dir/?api=1&origin=${widget.deliveryManModel?.latitude},${widget.deliveryManModel?.longitude}'
                              '&destination=${widget.addressModel?.latitude},${widget.addressModel?.longitude}&mode=d';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                          }
                        }
                      },
                    ),
                    InkWell(
                      hoverColor: Colors.grey,
                      onTap: (){
                        _startLocationUpdates();
                        _getDirections();
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 30,
                          width: 100,
                          margin: const EdgeInsets.only(top: 10 , right: 10),
                          alignment: Alignment.topRight,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: const Center(
                              child: Text('Reset' , style: TextStyle(color: Colors.white))
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(margin: const EdgeInsets.only(top: 100) , child: const Text('Rider data not found'))
        : const SizedBox.shrink();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
