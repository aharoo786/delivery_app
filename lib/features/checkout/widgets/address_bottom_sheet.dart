import 'dart:collection';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../common/enums/order_type_enum.dart';
import '../../../common/models/config_model.dart';
import '../../../common/models/delivery_info_model.dart';
import '../../../common/widgets/custom_shadow_widget.dart';
import '../../../helper/checkout_helper.dart';
import '../../../helper/price_converter_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../../order/enums/delivery_charge_type.dart';
import '../../splash/providers/splash_provider.dart';
import 'delivery_address_widget.dart';

class AddressBottomSheet extends StatefulWidget {
  // AddressBottomSheet({super.key});

  final double amount;
  final String? orderType;
  final double? discount;
  final double? couponDiscount;
  final String? couponCode;
  final String freeDeliveryType;
  final double? tax;
  final double? weight;
  final ConfigModel configModel;
  final bool selfPickup;
  final List<Branches> branches;
  const AddressBottomSheet(
      {super.key,
      required this.amount,
      required this.orderType,
      required this.discount,
      required this.couponDiscount,
      required this.couponCode,
      required this.freeDeliveryType,
      required this.tax,
      required this.configModel,
      required this.selfPickup,
      required this.branches,
      required this.weight});

  @override
  State<AddressBottomSheet> createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet> {
  // List<Branches>? _branches = [];

  Set<Marker> _markers = HashSet<Marker>();
  GoogleMapController? _mapController;
  final GlobalKey dropDownKey = GlobalKey();
  final TextEditingController searchController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OrderProvider, SplashProvider>(builder: (context, orderProvider, splashProvider, child) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            GestureDetector(onTap: (){
              Navigator.pop(context);
            }, child: const Icon(Icons.keyboard_arrow_down_outlined)),
            if (widget.branches?.isNotEmpty ?? false)
              CustomShadowWidget(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  (widget.configModel.googleMapStatus ?? false)
                      ? Container(
                          height: 200,
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).cardColor,
                          ),
                          child: Stack(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                              child: GoogleMap(
                                minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                                mapType: MapType.normal,
                                initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                      double.parse(widget.branches[0].latitude!),
                                      double.parse(widget.branches[0].longitude!),
                                    ),
                                    zoom: 8),
                                zoomControlsEnabled: true,
                                markers: _markers,
                                onMapCreated: (GoogleMapController controller) async {
                                  await Geolocator.requestPermission();
                                  _mapController = controller;
                                  _loading = false;
                                  _setMarkers(0);
                                },
                              ),
                            ),
                            _loading
                                ? Center(
                                    child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                  ))
                                : const SizedBox(),
                          ]),
                        )
                      : const SizedBox.shrink(),
                ]),
              ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            if (CheckOutHelper.getDeliveryChargeType() == DeliveryChargeType.area.name && !(widget.orderType == OrderType.self_pickup.name)) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Text(
                  getTranslated('zip_area', context),
                  style: poppinsSemiBold.copyWith(
                    fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Row(children: [
                  Expanded(
                      child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                    key: dropDownKey,
                    iconStyleData: IconStyleData(icon: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).hintColor)),
                    isExpanded: true,
                    hint: Text(
                      getTranslated('search_or_select_zip_code_area', context),
                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor),
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return (splashProvider.deliveryInfoModelList?[orderProvider.branchIndex].deliveryChargeByArea ?? []).map<Widget>((DeliveryChargeByArea item) {
                        return Row(children: [
                          Text(
                            item.areaName ?? "",
                            style: poppinsSemiBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          Text(
                            " (${PriceConverterHelper.convertPrice(context, item.deliveryCharge ?? 0)})",
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ]);
                      }).toList();
                    },
                    items: (splashProvider.deliveryInfoModelList?[orderProvider.branchIndex].deliveryChargeByArea ?? [])
                        .map((DeliveryChargeByArea item) => DropdownMenuItem<String>(
                              value: item.id.toString(),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(item.areaName ?? "",
                                    style: poppinsRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    )),
                                Text(
                                  " (${PriceConverterHelper.convertPrice(context, item.deliveryCharge ?? 0)})",
                                  style: poppinsRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ]),
                            ))
                        .toList(),
                    value: orderProvider.selectedAreaID == null
                        ? null
                        : splashProvider.deliveryInfoModelList?[orderProvider.branchIndex].deliveryChargeByArea!
                            .firstWhere((area) => area.id == orderProvider.selectedAreaID)
                            .id
                            .toString(),
                    onChanged: (String? value) {
                      orderProvider.setAreaID(areaID: int.parse(value!));
                      double deliveryCharge;
                      deliveryCharge = CheckOutHelper.getDeliveryCharge(
                        freeDeliveryType: widget.freeDeliveryType,
                        orderAmount: widget.amount,
                        distance: orderProvider.distance,
                        discount: widget.discount ?? 0,
                        configModel: widget.configModel,
                      );

                      orderProvider.setDeliveryCharge(deliveryCharge);
                      print("------------------------(DELIVERY CHARGE after change)------------- ${orderProvider.deliveryCharge}");
                    },
                    dropdownSearchData: DropdownSearchData(
                      searchController: searchController,
                      searchInnerWidgetHeight: 50,
                      searchInnerWidget: Container(
                        height: 50,
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
                        child: TextFormField(
                          controller: searchController,
                          expands: true,
                          maxLines: null,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            hintText: getTranslated('search_zip_area_name', context),
                            hintStyle: const TextStyle(fontSize: Dimensions.fontSizeSmall),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        DeliveryChargeByArea areaItem = (splashProvider.deliveryInfoModelList?[orderProvider.branchIndex].deliveryChargeByArea ?? [])
                            .firstWhere((element) => element.id.toString() == item.value);
                        return areaItem.areaName?.toLowerCase().contains(searchValue.toLowerCase()) ?? false;
                      },
                    ),
                    buttonStyleData: ButtonStyleData(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                      ),
                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                    ),
                  ))),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              // DeliveryAddressWidget(selfPickup: widget.selfPickup),
            ],
            DeliveryAddressWidget(selfPickup: widget.selfPickup),
          ],
        ),
      );
    });
  }

  void _setMarkers(int selectedIndex) async {
    late BitmapDescriptor bitmapDescriptor;
    late BitmapDescriptor bitmapDescriptorUnSelect;
    await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(25, 30)), Images.restaurantMarker).then((marker) {
      bitmapDescriptor = marker;
    });
    await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(20, 20)), Images.unselectedRestaurantMarker).then((marker) {
      bitmapDescriptorUnSelect = marker;
    });
    // Marker
    _markers = HashSet<Marker>();
    for (int index = 0; index < widget.branches.length; index++) {
      _markers.add(Marker(
        markerId: MarkerId('branch_$index'),
        position: LatLng(double.tryParse(widget.branches[index].latitude!)!, double.tryParse(widget.branches[index].longitude!)!),
        infoWindow: InfoWindow(title: widget.branches[index].name, snippet: widget.branches[index].address),
        icon: selectedIndex == index ? bitmapDescriptor : bitmapDescriptorUnSelect,
      ));
    }

    if (_mapController != null) {
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(
            double.tryParse(widget.branches[selectedIndex].latitude!)!,
            double.tryParse(widget.branches[selectedIndex].longitude!)!,
          ),
          zoom: ResponsiveHelper.isMobile() ? 12 : 16)));
    }

    setState(() {});
  }
}
