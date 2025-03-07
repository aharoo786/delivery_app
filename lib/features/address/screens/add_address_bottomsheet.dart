import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart';

import '../../../common/widgets/custom_app_bar_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/country_code_picker_widget.dart';
import '../../profile/providers/profile_provider.dart';
import '../../splash/providers/splash_provider.dart';
import '../domain/models/address_model.dart';
import '../providers/location_provider.dart';
import '../widgets/add_address_widget.dart';
import '../widgets/address_details_widget.dart';
import '../widgets/map_with_lable_widget.dart';

class AddAddressBottomsheet extends StatefulWidget {
  final bool isEnableUpdate;
  final bool fromCheckout;
  final bool fromStart;
  final bool fromManualAddAddress;
  final AddressModel? address;
  const AddAddressBottomsheet(
      {super.key,
      this.isEnableUpdate = true,
      this.fromStart = false,
      this.fromManualAddAddress = false,
      this.address,
      this.fromCheckout = false});

  @override
  State<AddAddressBottomsheet> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddAddressBottomsheet> {
  final TextEditingController _contactPersonNameController =
      TextEditingController();
  final TextEditingController _contactPersonNumberController =
      TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _florNumberController = TextEditingController();

  final FocusNode _addressNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  final FocusNode _stateNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();

  String? countryCode;

  @override
  void initState() {
    super.initState();

    _initLoading();

    if (widget.address != null && !widget.fromCheckout) {
      Provider.of<LocationProvider>(context, listen: false).setAddress =
          widget.address?.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('_AddNewAddressScreenState.build ${widget.fromStart}');
    print(
        'Addd address screen manuall address : ${widget.fromManualAddAddress}');

    return Container(
      color: Colors.white,
      child: Consumer<LocationProvider>(
          builder: (context, locationProvider, child) {
        return Column(children: [
          CustomAppBarWidget(
            title: widget.isEnableUpdate
                ? getTranslated('update_address', context)
                : getTranslated('add_new_address', context),
          ),
          Expanded(
              child: CustomScrollView(slivers: [
            SliverToBoxAdapter(
                child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Center(
                  child: SizedBox(
                      width: Dimensions.webScreenWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!ResponsiveHelper.isDesktop(context))
                            MapWithLabelWidget(
                              isEnableUpdate: widget.isEnableUpdate,
                              fromCheckout: widget.fromCheckout,
                              address: widget.address,
                              fromManualAddAddress: widget.fromManualAddAddress,
                            ),

                          // for label us
                          if (!ResponsiveHelper.isDesktop(context))
                            AddressDetailsWidget(
                              contactPersonNameController:
                                  _contactPersonNameController,
                              contactPersonNumberController:
                                  _contactPersonNumberController,
                              addressNode: _addressNode,
                              nameNode: _nameNode,
                              numberNode: _numberNode,
                              fromCheckout: widget.fromCheckout,
                              address: widget.address,
                              isEnableUpdate: widget.isEnableUpdate,
                              streetNumberController: _streetNumberController,
                              houseNumberController: _houseNumberController,
                              houseNode: _houseNode,
                              stateNode: _stateNode,
                              florNumberController: _florNumberController,
                              florNode: _floorNode,
                              countryCode: countryCode!,
                              onValueChange: (code) {
                                countryCode = code;
                              },
                            ),
                        ],
                      ))),
            )),
          ])),
          if (!ResponsiveHelper.isDesktop(context))
            AddAddressWidget(
                isEnableUpdate: widget.isEnableUpdate,
                fromCheckout: widget.fromCheckout,
                contactPersonNumberController: _contactPersonNumberController,
                contactPersonNameController: _contactPersonNameController,
                address: widget.address,
                streetNumberController: _streetNumberController,
                houseNumberController: _houseNumberController,
                floorNumberController: _florNumberController,
                countryCode: countryCode!,
                fromStart: widget.fromStart,
                fromManualAddAddress: widget.fromManualAddAddress),
        ]);
      }),
    );
  }

  Future<void> _initLoading() async {
    countryCode = CountryCode.fromCountryCode(
            Provider.of<SplashProvider>(context, listen: false)
                .configModel!
                .country!)
        .code;

    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);
    final userModel =
        Provider.of<ProfileProvider>(context, listen: false).userInfoModel;

    // locationProvider.setPickedAddressLatLon(null, null, isUpdate: false);

    if (widget.address == null) {
      locationProvider.setAddAddressData(false);
    }

    await locationProvider.initializeAllAddressType(context: context);
    locationProvider.updateAddressStatusMessage(message: '');
    locationProvider.onChangeErrorMessage(message: '');

    if (widget.isEnableUpdate && widget.address != null) {
      String? code =
          CountryPick.getCountryCode('${widget.address!.contactPersonNumber}');
      if (code != null) {
        countryCode = CountryCode.fromDialCode(code).code;
      }

      locationProvider.isUpdateAddress = false;

      if (splashProvider.configModel?.googleMapStatus ?? false) {
        if ((widget.address?.longitude?.isNotEmpty ?? false) &&
            (widget.address?.latitude?.isNotEmpty ?? false)) {
          locationProvider.setPickedAddressLatLon(
              widget.address?.latitude ?? '', widget.address?.longitude ?? '');
          locationProvider.updatePosition(
            CameraPosition(
                target: LatLng(
              double.parse(widget.address?.latitude ?? '0'),
              double.parse(widget.address?.longitude ?? '0'),
            )),
            true,
            widget.address!.address,
            forceNotify: false,
          );
        }
      }

      _contactPersonNameController.text =
          '${widget.address?.contactPersonName}';
      _contactPersonNumberController.text =
          '${widget.address?.contactPersonNumber}';
      _streetNumberController.text = widget.address?.streetNumber ?? '';
      _houseNumberController.text = widget.address?.houseNumber ?? '';
      _florNumberController.text = widget.address?.floorNumber ?? '';

      if (widget.address?.addressType == 'Home') {
        locationProvider.updateAddressIndex(0, false);
      } else if (widget.address!.addressType == 'Workplace') {
        locationProvider.updateAddressIndex(1, false);
      } else {
        locationProvider.updateAddressIndex(2, false);
      }
    } else {
      if (authProvider.isLoggedIn()) {
        String? code = CountryPick.getCountryCode(userModel?.phone);

        if (code != null) {
          countryCode = CountryCode.fromDialCode(code).code;
        }
        _contactPersonNameController.text =
            '${userModel?.fName ?? ''}' ' ${userModel?.lName ?? ''}';
        _contactPersonNumberController.text = (code != null
            ? (userModel?.phone ?? '').replaceAll(code, '')
            : userModel?.phone ?? '');
      }
    }

    print(
        "----------------(ADD NEW ADDRESS SCREEN)-------------${locationProvider.pickedAddressLatitude} and ${locationProvider.pickedAddressLongitude}");
  }
}
