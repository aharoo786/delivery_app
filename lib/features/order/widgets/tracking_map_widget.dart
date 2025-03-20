import 'dart:collection';
import 'dart:ui';
import 'dart:convert' as dartCoverter;
import 'package:http/http.dart' as http;


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/features/order/domain/models/delivery_man_model.dart';
import 'package:flutter_grocery/features/order/domain/models/order_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackingMapWidget extends StatefulWidget {
  final DeliveryManModel? deliveryManModel;
  final String? orderID;
  final int? branchID;
  final DeliveryAddress? addressModel;
  const TrackingMapWidget({super.key, required this.deliveryManModel, required this.orderID, required this.addressModel, required this.branchID});

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  GoogleMapController? _controller;
  bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  late LatLng _deliveryBoyLatLng;
  late LatLng _addressLatLng;
  LatLng? _restaurantLatLng;
  Set<Polyline> _polylines = {}; // Store route

  @override
  void initState() {
    super.initState();

    LatLng? branchLatLong;
    for (Branches branch in Provider.of<SplashProvider>(context, listen: false).configModel!.branches!) {
      if (branch.id == widget.branchID) {
        branchLatLong = LatLng(double.parse(branch.latitude!), double.parse(branch.longitude!));
        break;
      }
    }

    print("----------(MODEL)--------${widget.deliveryManModel?.latitude} and ${widget.deliveryManModel?.longitude}");
    print("----------(MODEL)--------${widget.addressModel?.latitude} and ${widget.addressModel?.longitude}");

    _deliveryBoyLatLng = widget.deliveryManModel != null
        ? LatLng(double.parse(widget.deliveryManModel?.latitude ?? '0'), double.parse(widget.deliveryManModel?.longitude ?? '0'))
        : const LatLng(0, 0);
    _addressLatLng = widget.addressModel != null
        ? LatLng(double.parse((widget.addressModel?.latitude?.isNotEmpty ?? false) ? widget.addressModel!.latitude! : '0'),
            double.parse(((widget.addressModel?.longitude?.isNotEmpty ?? false)) ? widget.addressModel!.longitude! : '0'))
        : const LatLng(0, 0);
    _restaurantLatLng = branchLatLong;

    // Fetch route
    if (_deliveryBoyLatLng.latitude != 0 && _addressLatLng.latitude != 0) {
      _fetchRoute();
    }
  }

  @override
  void dispose() {
    super.dispose();

    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel? configModel = Provider.of<SplashProvider>(context, listen: false).configModel;
    final width = MediaQuery.of(context).size.width;

    return (configModel?.googleMapStatus ?? false)
        ? Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: widget.deliveryManModel?.latitude != null
                ? Stack(children: [
                    GoogleMap(
                      minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(target: _addressLatLng, zoom: 18),
                      zoomControlsEnabled: true,
                      markers: _markers,
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                        _isLoading = false;
                        setMarker();
                      },
                      onTap: (latLng) async {
                        await Provider.of<OrderProvider>(context, listen: false).getDeliveryManData(widget.orderID, context);
                        String url = 'https://www.google.com/maps/dir/?api=1&origin=${widget.deliveryManModel!.latitude},${widget.deliveryManModel!.longitude}'
                            '&destination=${_addressLatLng.latitude},${_addressLatLng.longitude}&mode=d';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                    _isLoading ? Center(child: CustomLoaderWidget(color: Theme.of(context).primaryColor)) : const SizedBox(),
                  ])
                : SizedBox(height: 200, child: Center(child: Text(getTranslated('no_delivery_man_data_found', context)))),
          )
        : const SizedBox.shrink();
  }

  // Function to get route between delivery boy and destination
  Future<void> _fetchRoute() async {

    // 22.291225, 70.779596

    String apiKey = 'AIzaSyBNfDDSWLMTtVpDy58bnhhU4x_1jLoJnJA';
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_deliveryBoyLatLng.latitude},${_deliveryBoyLatLng.longitude}&destination=${_addressLatLng.latitude},${_addressLatLng.longitude}&mode=driving&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = dartCoverter.jsonDecode(response.body);
      if (data['routes'].isNotEmpty) {
        String encodedPolyline = data['routes'][0]['overview_polyline']['points'];
        List<LatLng> polylineCoordinates = _decodePolyline(encodedPolyline);

        setState(() {
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            width: 5,
            points: polylineCoordinates,
          ));
        });
      }
    }
  }

  // Decode polyline
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void setMarker() async {
    Uint8List restaurantImageData = await convertAssetToUnit8List(Images.restaurantMarker, width: 50);
    Uint8List deliveryBoyImageData = await convertAssetToUnit8List(Images.deliveryBoyMarker, width: 50);
    Uint8List destinationImageData = await convertAssetToUnit8List(Images.destinationMarker, width: 50);

    // Animate to coordinate
    LatLngBounds? bounds;
    double rotation = 0;
    if (_controller != null) {
      if (_addressLatLng.latitude < _restaurantLatLng!.latitude) {
        bounds = LatLngBounds(southwest: _addressLatLng, northeast: _restaurantLatLng!);
        rotation = 0;
      } else {
        bounds = LatLngBounds(southwest: _restaurantLatLng!, northeast: _addressLatLng);
        rotation = 180;
      }
    }
    LatLng centerBounds = LatLng((bounds!.northeast.latitude + bounds.southwest.latitude) / 2, (bounds.northeast.longitude + bounds.southwest.longitude) / 2);

    _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: 17)));
    if (ResponsiveHelper.isMobilePhone()) {
      zoomToFit(_controller, bounds, centerBounds);
    }

    // Marker
    _markers = HashSet<Marker>();
    _markers.add(Marker(
      markerId: const MarkerId('destination'),
      position: _addressLatLng,
      infoWindow: InfoWindow(
        title: 'Destination',
        snippet: '${_addressLatLng.latitude}, ${_addressLatLng.longitude}',
      ),
      icon: BitmapDescriptor.fromBytes(destinationImageData),
    ));

    _markers.add(Marker(
      markerId: const MarkerId('restaurant'),
      position: _restaurantLatLng!,
      infoWindow: InfoWindow(
        title: 'Restaurant',
        snippet: '${_restaurantLatLng!.latitude}, ${_restaurantLatLng!.longitude}',
      ),
      icon: BitmapDescriptor.fromBytes(restaurantImageData),
    ));
    widget.deliveryManModel!.latitude != null
        ? _markers.add(Marker(
            markerId: const MarkerId('delivery_boy'),
            position: _deliveryBoyLatLng,
            infoWindow: InfoWindow(
              title: 'Delivery Man',
              snippet: '${_deliveryBoyLatLng.latitude}, ${_deliveryBoyLatLng.longitude}',
            ),
            rotation: rotation,
            icon: BitmapDescriptor.fromBytes(deliveryBoyImageData),
          ))
        : const SizedBox();

    setState(() {});
  }

  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds, LatLng centerBounds) async {
    bool keepZoomingOut = true;

    while (keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if (fits(bounds!, screenBounds)) {
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - 0.5;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      } else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }
}
