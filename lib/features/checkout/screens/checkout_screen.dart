import 'dart:collection';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/enums/order_type_enum.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/models/delivery_info_model.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/common/providers/localization_provider.dart';
import 'package:flutter_grocery/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_shadow_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_single_child_list_widget.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/not_login_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/address/domain/models/address_model.dart';
import 'package:flutter_grocery/features/address/providers/location_provider.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/checkout/domain/models/check_out_model.dart';
import 'package:flutter_grocery/features/checkout/widgets/delivery_address_widget.dart';
import 'package:flutter_grocery/features/checkout/widgets/details_widget.dart';
import 'package:flutter_grocery/features/checkout/widgets/place_order_button_widget.dart';
import 'package:flutter_grocery/features/order/enums/delivery_charge_type.dart';
import 'package:flutter_grocery/features/order/providers/image_note_provider.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/checkout_helper.dart';
import 'package:flutter_grocery/helper/date_converter_helper.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../helper/cart_helper.dart';
import '../../../utill/color_resources.dart';
import '../../cart/widgets/cart_button_widget.dart';
import '../../cart/widgets/cart_details_widget.dart';
import '../../coupon/providers/coupon_provider.dart';
import '../widgets/address_bottom_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  final double amount;
  final String? orderType;
  final double? discount;
  final double? couponDiscount;
  final String? couponCode;
  final String freeDeliveryType;
  final double? tax;
  final double? weight;
  const CheckoutScreen(
      {super.key,
      required this.amount,
      required this.orderType,
      required this.discount,
      required this.couponDiscount,
      required this.couponCode,
      required this.freeDeliveryType,
      required this.tax,
      required this.weight});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  final ScrollController scrollController = ScrollController();
  final GlobalKey dropDownKey = GlobalKey();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  List<Branches>? _branches = [];
  late bool _isLoggedIn;
  List<PaymentMethod> _activePaymentList = [];
  late bool selfPickup;

  @override
  void initState() {
    super.initState();

    initLoading();
  }

  void openDialog(BuildContext context , ConfigModel configModel) {
    ResponsiveHelper.showDialogOrBottomSheet(
      context,

      SizedBox(
        height: MediaQuery.of(context).size.height *0.8,
        child: AddressBottomSheet(
          amount: widget.amount,
          orderType: widget.orderType,
          discount: widget.discount,
          couponDiscount: widget.couponDiscount,
          couponCode: widget.couponCode,
          freeDeliveryType: widget.freeDeliveryType,
          tax: widget.tax,
          weight: widget.weight, configModel: configModel, selfPickup: selfPickup, branches: _branches ?? [],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final bool isRoute = (_isLoggedIn || (configModel.isGuestCheckout! && authProvider.getGuestId() != null));

    double weightCharge = 0.0;
    if (widget.orderType == OrderType.delivery.name) {
      weightCharge = CheckOutHelper.weightChargeCalculation(widget.weight, splashProvider.deliveryInfoModelList?[orderProvider.branchIndex]);
    }

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: (ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
          : CustomAppBarWidget(title: getTranslated('checkout', context))) as PreferredSizeWidget?,
      body: isRoute
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                Expanded(
                    child: CustomScrollView(controller: scrollController, slivers: [
                  SliverToBoxAdapter(child: Consumer<OrderProvider>(
                    builder: (context, orderProvider, child) {
                      double deliveryCharge = CheckOutHelper.getDeliveryCharge(
                        freeDeliveryType: widget.freeDeliveryType,
                        orderAmount: widget.amount,
                        distance: orderProvider.distance,
                        discount: widget.discount ?? 0,
                        configModel: configModel,
                      );

                      orderProvider.setDeliveryCharge(deliveryCharge, notify: false);
                      orderProvider.getCheckOutData?.copyWith(deliveryCharge: orderProvider.deliveryCharge, orderNote: _noteController.text);

                      return Consumer2<LocationProvider, CartProvider>(builder: (context, address, cart, child) {
                        double itemPrice = 0;
                        double discount = 0;
                        double tax = 0;

                        for (var cartModel in cart.cartList) {
                          itemPrice = itemPrice + (cartModel.price! * cartModel.quantity!);
                          discount = discount + (cartModel.discount! * cartModel.quantity!);
                          tax = tax + (cartModel.tax! * cartModel.quantity!);
                        }

                        double subTotal = itemPrice + (configModel.isVatTexInclude! ? 0 : tax);
                        bool isFreeDelivery = subTotal >= configModel.freeDeliveryOverAmount! && configModel.freeDeliveryStatus! ||
                            Provider.of<CouponProvider>(context, listen: false).coupon?.couponType == 'free_delivery';

                        double total = subTotal - discount - Provider.of<CouponProvider>(context).discount!;

                        double weight = 0.0;
                        weight = CartHelper.weightCalculation(cart.cartList);
                        return Column(
                          children: [
                            Center(
                                child: SizedBox(
                                    width: Dimensions.webScreenWidth,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 6,
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              const SizedBox(height: Dimensions.paddingSizeSmall),

                                              Consumer<LocationProvider>(
                                                builder: (context , locationProvider , child) {
                                                  AddressModel? deliveryAddress = CheckOutHelper.getDeliveryAddress(
                                                    addressList: locationProvider.addressList,
                                                    selectedAddress: orderProvider.addressIndex == -1 ? null : locationProvider.addressList?[orderProvider.addressIndex],
                                                    lastOrderAddress: null,
                                                  );
                                                  return InkWell(
                                                    onTap: () => openDialog(context , configModel),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Flexible(
                                                          child: Row(
                                                            children: [
                                                              /// **Payment Icon**
                                                              const Icon(Icons.location_on_outlined, size: 24, color: Colors.black),
                                                              const SizedBox(width: Dimensions.paddingSizeSmall),
                                                          
                                                              /// **Payment Title & Subtitle**
                                                              Flexible(
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                      "Delivery Address",
                                                                      style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black),
                                                                    ),
                                                                    Text(
                                                                      deliveryAddress?.address  ?? "Address here",
                                                                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        /// **Arrow Icon**
                                                        const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black),
                                                      ],
                                                    ),
                                                  );
                                                }
                                              ),

                                              //if(orderProvider.orderType != OrderType.takeAway && splashProvider.deliveryInfoModel != null && (splashProvider.deliveryInfoModel!.deliveryChargeByArea?.isNotEmpty ?? false) && splashProvider.deliveryInfoModel?.deliveryChargeSetup?.deliveryChargeType == 'area')...[

                                              if (!ResponsiveHelper.isDesktop(context)) ...{
                                                DetailsWidget(paymentList: _activePaymentList, noteController: _noteController),
                                              },

                                              CartDetailsWidget(
                                                  couponController: TextEditingController(text: Provider.of<CouponProvider>(context, listen: false).coupon?.code ?? ''),
                                                  total: total,
                                                  isFreeDelivery: isFreeDelivery,
                                                  itemPrice: itemPrice,
                                                  tax: tax,
                                                  discount: discount),
                                            ])),
                                        if (ResponsiveHelper.isDesktop(context))
                                          Expanded(
                                            flex: 4,
                                            child: Column(children: [
                                              DetailsWidget(paymentList: _activePaymentList, noteController: _noteController),
                                              PlaceOrderButtonWidget(
                                                  discount: widget.discount ?? 0.0,
                                                  couponDiscount: widget.couponDiscount,
                                                  tax: widget.tax,
                                                  scrollController: scrollController,
                                                  dropdownKey: dropDownKey,
                                                  weight: weightCharge),
                                            ]),
                                          ),
                                      ],
                                    ))),
                          ],
                        );
                      });
                    },
                  )),
                  const FooterWebWidget(footerType: FooterType.sliver),
                ])),
                if (!ResponsiveHelper.isDesktop(context))
                  Center(
                      child: PlaceOrderButtonWidget(
                          discount: widget.discount ?? 0.0,
                          couponDiscount: widget.couponDiscount,
                          tax: widget.tax,
                          scrollController: scrollController,
                          dropdownKey: dropDownKey,
                          weight: weightCharge)),
              ]),
            )
          : const NotLoggedInWidget(),
    );
  }

  Future<void> initLoading() async {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    final OrderImageNoteProvider orderImageNoteProvider = Provider.of<OrderImageNoteProvider>(context, listen: false);

    orderProvider.clearPrevData();
    orderImageNoteProvider.onPickImage(true, isUpdate: false);
    splashProvider.getOfflinePaymentMethod(true);

    _isLoggedIn = authProvider.isLoggedIn();

    selfPickup = CheckOutHelper.isSelfPickup(orderType: widget.orderType ?? '');
    orderProvider.setOrderType(widget.orderType, notify: false);
    orderProvider.setAreaID(isUpdate: false, isReload: true);
    orderProvider.setDeliveryCharge(null, notify: false);

    orderProvider.setCheckOutData = CheckOutModel(
      orderType: widget.orderType,
      deliveryCharge: 0,
      freeDeliveryType: widget.freeDeliveryType,
      amount: widget.amount,
      placeOrderDiscount: widget.discount,
      couponCode: widget.couponCode,
      orderNote: null,
    );

    if (_isLoggedIn || CheckOutHelper.isGuestCheckout()) {
      orderProvider.setAddressIndex(-1, notify: false);
      orderProvider.initializeTimeSlot();
      _branches = splashProvider.configModel!.branches;

      await locationProvider.initAddressList();
      AddressModel? lastOrderedAddress;

      if (_isLoggedIn && widget.orderType == 'delivery') {
        lastOrderedAddress = await locationProvider.getLastOrderedAddress();
      }

      CheckOutHelper.selectDeliveryAddressAuto(orderType: widget.orderType, isLoggedIn: (_isLoggedIn || CheckOutHelper.isGuestCheckout()), lastAddress: lastOrderedAddress);
    }
    _activePaymentList = CheckOutHelper.getActivePaymentList(configModel: splashProvider.configModel!);
  }

  // void _setMarkers(int selectedIndex) async {
  //   late BitmapDescriptor bitmapDescriptor;
  //   late BitmapDescriptor bitmapDescriptorUnSelect;
  //   await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(25, 30)), Images.restaurantMarker).then((marker) {
  //     bitmapDescriptor = marker;
  //   });
  //   await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(20, 20)), Images.unselectedRestaurantMarker).then((marker) {
  //     bitmapDescriptorUnSelect = marker;
  //   });
  //   // Marker
  //   _markers = HashSet<Marker>();
  //   for (int index = 0; index < _branches!.length; index++) {
  //     _markers.add(Marker(
  //       markerId: MarkerId('branch_$index'),
  //       position: LatLng(double.tryParse(_branches![index].latitude!)!, double.tryParse(_branches![index].longitude!)!),
  //       infoWindow: InfoWindow(title: _branches![index].name, snippet: _branches![index].address),
  //       icon: selectedIndex == index ? bitmapDescriptor : bitmapDescriptorUnSelect,
  //     ));
  //   }
  //
  //   if (_mapController != null) {
  //     _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //         target: LatLng(
  //           double.tryParse(_branches![selectedIndex].latitude!)!,
  //           double.tryParse(_branches![selectedIndex].longitude!)!,
  //         ),
  //         zoom: ResponsiveHelper.isMobile() ? 12 : 16)));
  //   }
  //
  //   setState(() {});
  // }
}
