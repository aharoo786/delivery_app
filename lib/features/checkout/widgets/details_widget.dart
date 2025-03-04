import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/features/checkout/domain/models/check_out_model.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/features/checkout/widgets/image_note_upload_widget.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_shadow_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter_grocery/features/checkout/widgets/payment_section_widget.dart';
import 'package:provider/provider.dart';

import '../../../common/providers/localization_provider.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../common/widgets/custom_single_child_list_widget.dart';
import '../../../helper/checkout_helper.dart';
import '../../../helper/date_converter_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../utill/color_resources.dart';
import '../../../utill/images.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../splash/providers/splash_provider.dart';
import 'partial_pay_widget.dart';

class DetailsWidget extends StatelessWidget {
  const DetailsWidget({
    super.key,
    required this.paymentList,
    required this.noteController,
  });

  final List<PaymentMethod> paymentList;
  final TextEditingController noteController;

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool isPartialPayment = CheckOutHelper.isPartialPayment(
      configModel: splashProvider.configModel!,
      isLogin: authProvider.isLoggedIn(),
      userInfoModel: profileProvider.userInfoModel,
    );
    CheckOutModel? checkOutData = Provider.of<OrderProvider>(context, listen: false).getCheckOutData;

    return Consumer2<CartProvider, OrderProvider>(builder: (context, cart, orderProvider, child) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PaymentSectionWidget(),

        const SizedBox(height: Dimensions.paddingSizeDefault),
        const Divider(color: ColorResources.borderColor),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        if (isPartialPayment) ...{
          PartialPayWidget(totalPrice: (checkOutData?.amount ?? 0) + (checkOutData?.deliveryCharge ?? 0)),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          const Divider(color: ColorResources.borderColor),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        },
        const ImageNoteUploadWidget(),

        const SizedBox(height: Dimensions.paddingSizeDefault),
        const Divider(color: ColorResources.borderColor),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Text('Delivery Time', style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                cart.showSchedule0rStandard(true, false);
              },
              child: Container(
                width: 150,
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                decoration: cart.isShowStandardTime
                    ? BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black, width: 1))
                    : BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: ColorResources.borderColor, width: 1)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Images.clock,
                      height: 20,
                      width: 20,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Standard',
                          style: poppinsRegular.copyWith(color: Colors.black, fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600
                              // color: categoryProvider.selectedCategoryIndex == -1 ? Theme.of(context).canvasColor : Colors.black ,
                              ),
                        ),
                        Text(
                          '20-30 Mins',
                          style: poppinsRegular.copyWith(color: Colors.black, fontWeight: FontWeight.w400, fontSize: Dimensions.fontSizeSmall
                              // color: categoryProvider.selectedCategoryIndex == -1 ? Theme.of(context).canvasColor : Colors.black ,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                cart.showSchedule0rStandard(false, true);
              },
              child: Container(
                width: 150,
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
                // alignment: Alignment.center,
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                decoration: cart.isShowScheduleTime
                    ? BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black, width: 1))
                    : BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: ColorResources.borderColor, width: 1)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Images.dateIcon,
                      height: 20,
                      width: 20,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Schedule',
                          style: poppinsRegular.copyWith(color: Colors.black, fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600
                              // color: categoryProvider.selectedCategoryIndex == -1 ? Theme.of(context).canvasColor : Colors.black ,
                              ),
                        ),
                        Text(
                          'Select Time',
                          style: poppinsRegular.copyWith(color: Colors.black, fontWeight: FontWeight.w400, fontSize: Dimensions.fontSizeSmall
                              // color: categoryProvider.selectedCategoryIndex == -1 ? Theme.of(context).canvasColor : Colors.black ,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (cart.isShowScheduleTime)
          // Time Slot
          CustomShadowWidget(
            child: Align(
              alignment: Provider.of<LocalizationProvider>(context, listen: false).isLtr ? Alignment.topLeft : Alignment.topRight,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
                  child: Row(children: [
                    Text(getTranslated('preference_time', context),
                        style: poppinsMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        )),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Tooltip(
                      triggerMode: ResponsiveHelper.isDesktop(context) ? null : TooltipTriggerMode.tap,
                      message: getTranslated('select_your_preference_time', context),
                      child: Icon(Icons.info_outline, color: Theme.of(context).disabledColor, size: Dimensions.paddingSizeLarge),
                    ),
                  ]),
                ),
                CustomSingleChildListWidget(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          Radio(
                            activeColor: Theme.of(context).primaryColor,
                            value: index,
                            groupValue: orderProvider.selectDateSlot,
                            onChanged: (value) => orderProvider.updateDateSlot(index),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text(
                            index == 0
                                ? getTranslated('today', context)
                                : index == 1
                                    ? getTranslated('tomorrow', context)
                                    : DateConverterHelper.estimatedDate(DateTime.now().add(const Duration(days: 2))),
                            style: poppinsRegular.copyWith(
                              color: index == orderProvider.selectDateSlot ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        ]),
                      );
                    }),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                orderProvider.timeSlots == null
                    ? CustomLoaderWidget(color: Theme.of(context).primaryColor)
                    : CustomSingleChildListWidget(
                        scrollDirection: Axis.horizontal,
                        itemCount: orderProvider.timeSlots?.length ?? 0,
                        itemBuilder: (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            child: InkWell(
                              hoverColor: Colors.transparent,
                              onTap: () => orderProvider.updateTimeSlot(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: orderProvider.selectTimeSlot == index ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor,
                                      spreadRadius: .5,
                                      blurRadius: .5,
                                    )
                                  ],
                                  border: Border.all(
                                    color: orderProvider.selectTimeSlot == index ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.history, color: orderProvider.selectTimeSlot == index ? Theme.of(context).cardColor : Theme.of(context).disabledColor, size: 20),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                    Text(
                                      '${DateConverterHelper.stringToStringTime(orderProvider.timeSlots![index].startTime!, context)} '
                                      '- ${DateConverterHelper.stringToStringTime(orderProvider.timeSlots![index].endTime!, context)}',
                                      style: poppinsRegular.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: orderProvider.selectTimeSlot == index ? Theme.of(context).cardColor : Theme.of(context).disabledColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        const Divider(color: ColorResources.borderColor),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        CustomShadowWidget(
          child: CustomTextFieldWidget(
            fillColor: Theme.of(context).canvasColor,
            isShowBorder: true,
            controller: noteController,
            hintText: getTranslated('Add Delivery Instructions', context),
            inputType: TextInputType.multiline,
            inputAction: TextInputAction.newline,
            capitalization: TextCapitalization.sentences,
          ),
        ),
      ]);
    });
  }
}
