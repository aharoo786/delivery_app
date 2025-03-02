import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/features/address/screens/select_location_screen.dart';
import 'package:flutter_grocery/features/address/widgets/map_widget.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/custom_app_bar_widget.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../common/widgets/custom_text_field_widget.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../main.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../domain/models/address_model.dart';
import '../domain/models/prediction_model.dart';
import '../providers/location_provider.dart';
import '../widgets/map_with_lable_widget.dart';
import '../widgets/search_dialog_widget.dart';
import '../widgets/search_item_widget.dart';
import 'add_new_address_screen.dart';

class GiveAccessLocation extends StatelessWidget {
  const GiveAccessLocation({super.key, this.address});
  final AddressModel? address;

  @override
  Widget build(BuildContext context) {
    final LocationProvider locationProvider = Provider.of<LocationProvider>(context, listen: false);
    return Scaffold(
      appBar: CustomAppBarWidget(
        isBackButtonExist: false,
        title: getTranslated(
          '',
          context,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            MapWidget(
              height: 300,
              isEnableUpdate: true,
              fromCheckout: false,
              address: address,
            ),
            const Spacer(),
            Text(
              "Grant Current Location",
              style: poppinsBold.copyWith(fontSize: 24),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "This let us show nearby restaurants,\ntores you can order from",
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 40,
            ),
            CustomButtonWidget(
                buttonText: "Use current location",
                onPressed: () {
                  pushToAddAddress();
                }),
            const SizedBox(
              height: 12,
            ),
            CustomButtonWidget(
              buttonText: "Enter Manually",
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.9,
                        width: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.arrow_back, color: Colors.black)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Search for location",
                                    style: poppinsBold.copyWith(fontSize: 22),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  SizedBox(
                                      width: double.maxFinite,
                                      child: TypeAheadField<PredictionModel>(
                                        suggestionsCallback: (pattern) async => await locationProvider.searchLocation(context, pattern),
                                        builder: (context, controller, focusNode) => TextField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          textInputAction: TextInputAction.search,
                                          autofocus: true,
                                          textCapitalization: TextCapitalization.words,
                                          keyboardType: TextInputType.streetAddress,
                                          decoration: InputDecoration(
                                            hintText: getTranslated('e.g. BTM layout', context),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: const BorderSide(style: BorderStyle.none, width: 0),
                                            ),
                                            hintStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                                                  fontSize: Dimensions.fontSizeDefault,
                                                  color: Theme.of(context).disabledColor,
                                                ),
                                            filled: true,
                                            fillColor: const Color(0xffF2F2F3),
                                          ),
                                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                                color: Theme.of(context).textTheme.bodyLarge!.color,
                                                fontSize: Dimensions.fontSizeLarge,
                                              ),
                                        ),
                                        itemBuilder: (context, suggestion) => SearchItemWidget(suggestion: suggestion),
                                        onSelected: (PredictionModel suggestion) async {
                                          await locationProvider.setLocation(suggestion.placeId, suggestion.description, null);
                                          pushToAddAddress(isManual: true);
                                        },
                                        loadingBuilder: (context) => CustomLoaderWidget(color: Theme.of(context).primaryColor),
                                        errorBuilder: (context, error) => const SearchItemWidget(),
                                        emptyBuilder: (context) => const SearchItemWidget(),
                                      )),
                                  ListTile(
                                    onTap: () {
                                      pushToAddAddress();
                                    },
                                    visualDensity: const VisualDensity(horizontal: -4),
                                    leading: SvgPicture.asset(Images.currentLocationIcon),
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      "Use Current Location",
                                      style: poppinsSemiBold.copyWith(fontSize: 12),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              },
              backgroundColor: const Color(0xffF2F2F3),
              textColor: Colors.black,
            ),
            const SizedBox(
              height: 70,
            )
          ],
        ),
      ),
    );
  }

  void pushToAddAddress({isManual = false}) async {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Adjust the radius as needed
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          width: double.maxFinite,
          decoration: const BoxDecoration(
            color: Colors.white, // Ensure background color matches
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Rounded top corners
          ),
          child: AddNewAddressScreen(
            address: AddressModel(),
            fromStart: true,
            fromManualAddAddress: isManual,
          ),
        );
      },
    );

  }
}
