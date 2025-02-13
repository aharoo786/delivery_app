import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/features/address/domain/models/address_model.dart';
import 'package:flutter_grocery/features/address/widgets/map_with_lable_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/address/providers/location_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter_grocery/common/widgets/phone_number_field_widget.dart';
import 'package:flutter_grocery/features/address/widgets/add_address_widget.dart';
import 'package:provider/provider.dart';

class AddressDetailsWidget extends StatefulWidget {
  final TextEditingController contactPersonNameController;
  final TextEditingController contactPersonNumberController;
  final FocusNode addressNode;
  final FocusNode nameNode;
  final FocusNode numberNode;
  final bool isEnableUpdate;
  final bool fromCheckout;
  final AddressModel? address;
  final TextEditingController streetNumberController;
  final TextEditingController houseNumberController;
  final TextEditingController florNumberController;
  final FocusNode stateNode;
  final FocusNode houseNode;
  final FocusNode florNode;
  final String countryCode;
  final Function(String value) onValueChange;

  const AddressDetailsWidget({
    super.key,
    required this.contactPersonNameController,
    required this.contactPersonNumberController,
    required this.addressNode,
    required this.nameNode,
    required this.numberNode,
    required this.isEnableUpdate,
    required this.fromCheckout,
    required this.address,
    required this.streetNumberController,
    required this.houseNumberController,
    required this.stateNode,
    required this.houseNode,
    required this.florNumberController,
    required this.florNode,
    required this.countryCode,
    required this.onValueChange,
  });

  @override
  State<AddressDetailsWidget> createState() => _AddressDetailsWidgetState();
}

class _AddressDetailsWidgetState extends State<AddressDetailsWidget> {
  final TextEditingController locationTextController = TextEditingController();

  @override
  void dispose() {
    locationTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final ConfigModel? configModel =
        Provider.of<SplashProvider>(context, listen: false).configModel;
    final LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    if (!(configModel?.googleMapStatus ?? true)) {
      print("Here I am");
      locationTextController.text = locationProvider.address ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final ConfigModel? configModel =
        Provider.of<SplashProvider>(context, listen: false).configModel;
    final Size size = MediaQuery.of(context).size;
    print("----------(Address)---------${locationProvider.address}");

    return Container(
        decoration: ResponsiveHelper.isDesktop(context)
            ? BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: ColorResources.cartShadowColor.withOpacity(0.2),
                    blurRadius: 10,
                  )
                ],
              )
            : const BoxDecoration(),
        padding: ResponsiveHelper.isDesktop(context)
            ? const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeLarge,
              )
            : EdgeInsets.zero,
        child: Padding(
          padding: (configModel?.googleMapStatus ?? false)
              ? const EdgeInsets.all(0)
              : EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated('Delivery Address', context),
                      style: poppinsSemiBold.copyWith(fontSize: 20),
                    ),
                    SizedBox(
                      width: 200,
                      child: Text(
                        getTranslated('${locationProvider.address}', context),
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall!
                            .copyWith(
                                color: Theme.of(context)
                                    .hintColor
                                    .withOpacity(0.6),
                                fontSize: Dimensions.fontSizeLarge),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 72,
                  child: CustomButtonWidget(
                    borderRadius: 30,
                    backgroundColor: Colors.transparent,
                    textColor: Colors.black,
                    borderColor: Colors.grey,
                    textStyle: poppinsMedium.copyWith(
                        fontSize: 12, color: Colors.black),
                    buttonText: "Change",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    height: 36,
                    width: 72,
                  ),
                )
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(
              '${getTranslated('house', context)} / ${getTranslated('floor', context)} ${getTranslated('number', context)}',
              style: poppinsMedium.copyWith(fontSize: 16),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            CustomTextFieldWidget(
              hintText: getTranslated('ex_2', context),
              isShowBorder: true,
              inputType: TextInputType.streetAddress,
              inputAction: TextInputAction.next,
              focusNode: widget.houseNode,
              nextFocus: widget.florNode,
              controller: widget.houseNumberController,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // // for Address Field
            // Text(
            //   getTranslated('address_line_01', context),
            //   style: poppinsMedium.copyWith(fontSize: 16),
            // ),
            // const SizedBox(height: Dimensions.paddingSizeSmall),
            //
            // CustomTextFieldWidget(
            //   onChanged: (String? value) {
            //     locationProvider.setAddress = value;
            //   },
            //   hintText: getTranslated('address_line_02', context),
            //   isShowBorder: true,
            //   inputType: TextInputType.streetAddress,
            //   inputAction: TextInputAction.next,
            //   focusNode: widget.addressNode,
            //   nextFocus: widget.stateNode,
            //   controller: (configModel?.googleMapStatus ?? false)
            //       ? (locationTextController
            //         ..text = locationProvider.address ?? '')
            //       : locationTextController,
            // ),
            // const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(
              getTranslated('Apartment / Building name', context),
              style: poppinsMedium.copyWith(fontSize: 16),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            CustomTextFieldWidget(
              hintText: getTranslated('ex_10_th', context),
              isShowBorder: true,
              inputType: TextInputType.streetAddress,
              inputAction: TextInputAction.next,
              focusNode: widget.stateNode,
              nextFocus: widget.houseNode,
              controller: widget.streetNumberController,
            ),

            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(
              getTranslated('How to reach', context),
              style: poppinsMedium.copyWith(fontSize: 16),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            CustomTextFieldWidget(
              hintText: getTranslated('How to reach', context),
              isShowBorder: true,
              maxLines: 2,
              inputType: TextInputType.streetAddress,
              inputAction: TextInputAction.next,
              focusNode: widget.florNode,
              nextFocus: widget.nameNode,
              controller: widget.florNumberController,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // for Contact Person Name
            Text(
              getTranslated('contact_person_name', context),
              style: poppinsMedium.copyWith(fontSize: 16),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            CustomTextFieldWidget(
              hintText: getTranslated('enter_contact_person_name', context),
              isShowBorder: true,
              inputType: TextInputType.name,
              controller: widget.contactPersonNameController,
              focusNode: widget.nameNode,
              nextFocus: widget.numberNode,
              inputAction: TextInputAction.next,
              capitalization: TextCapitalization.words,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // for Contact Person Number
            Text(
              getTranslated('contact_person_number', context),
              style: poppinsMedium.copyWith(fontSize: 16),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            PhoneNumberFieldWidget(
              onValueChange: widget.onValueChange,
              countryCode: widget.countryCode,
              phoneNumberTextController: widget.contactPersonNumberController,
              phoneFocusNode: widget.numberNode,
            ),
          ]),
        ));
  }
}
