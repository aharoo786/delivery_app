import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter_grocery/helper/checkout_helper.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_shadow_widget.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:provider/provider.dart';

import 'payment_method_bottom_sheet_widget.dart';
class PaymentSectionWidget extends StatelessWidget {
  const PaymentSectionWidget({super.key});

  void openDialog(BuildContext context) {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (!CheckOutHelper.isSelfPickup(orderType: orderProvider.orderType) &&
        orderProvider.addressIndex == -1) {
      showCustomSnackBarHelper(
          getTranslated('select_delivery_address', context), isError: true);
    } else if (orderProvider.timeSlots == null || orderProvider.timeSlots!.isEmpty) {
      showCustomSnackBarHelper(getTranslated('select_a_time', context), isError: true);
    } else {
      ResponsiveHelper.showDialogOrBottomSheet(
        context,
        const PaymentMethodBottomSheetWidget(),
        isScrollControlled: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(builder: (context, orderProvider, _) {
      bool hasPaymentMethod = orderProvider.selectedPaymentMethod != null;

      return
        InkWell(
        onTap: () => openDialog(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                /// **Payment Icon**
                const Icon(Icons.credit_card, size: 24, color: Colors.black),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                /// **Payment Title & Subtitle**
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payment Method",
                      style: poppinsMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge, color: Colors.black),
                    ),
                    Text(
                      hasPaymentMethod
                          ? orderProvider.selectedPaymentMethod?.getWayTitle ?? ""
                          : "Add/Change Payment Method",
                      style: poppinsRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            /// **Arrow Icon**
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black),
          ],
        ),
      );
    });
  }
}



// class PaymentSectionWidget extends StatelessWidget {
//   const PaymentSectionWidget({super.key});
//
//   void openDialog(BuildContext context) {
//     final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);
//
//     if (!CheckOutHelper.isSelfPickup(orderType: orderProvider.orderType) && orderProvider.addressIndex == -1) {
//       showCustomSnackBarHelper(getTranslated('select_delivery_address', context), isError: true);
//     } else if (orderProvider.timeSlots == null || orderProvider.timeSlots!.isEmpty) {
//       showCustomSnackBarHelper(getTranslated('select_a_time', context), isError: true);
//     } else {
//       ResponsiveHelper.showDialogOrBottomSheet(context, const PaymentMethodBottomSheetWidget(), isScrollControlled: true);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<OrderProvider>(builder: (context, orderProvider, _) {
//       bool showPayment = orderProvider.selectedPaymentMethod != null;
//
//       return CustomShadowWidget(
//         child: Column(children: [
//           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             Text(getTranslated('payment_method', context), style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
//             Flexible(
//               child: TextButton(
//                 onPressed: () => openDialog(context),
//                 child: Text(
//                   getTranslated(orderProvider.partialAmount != null || !showPayment ? 'add' : 'change', context),
//                   style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor),
//                 ),
//               ),
//             )
//           ]),
//           const Divider(height: 1),
//           if (orderProvider.partialAmount != null || !showPayment)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
//               child: InkWell(
//                 onTap: () => openDialog(context),
//                 child: Row(children: [
//                   Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
//                   const SizedBox(width: Dimensions.paddingSizeDefault),
//                   Flexible(
//                     child: Text(
//                       getTranslated('add_payment_method', context),
//                       style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor),
//                     ),
//                   ),
//                 ]),
//               ),
//             ),
//           if (showPayment)
//             _SelectedPaymentView(total: orderProvider.partialAmount ?? ((orderProvider.getCheckOutData?.amount ?? 0) + (orderProvider.getCheckOutData?.deliveryCharge ?? 0))),
//         ]),
//       );
//     });
//   }
//
//   Widget _cartScreenWidget({context, icon, text, subTitle, isImage, promoCodeText = '', isPromoCode = false}) {
//     return Row(
//       children: [
//         isImage ? Image.asset(icon, height: 20) : Icon(icon, color: Colors.black, size: 20),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 text,
//                 style: poppinsSemiBold.copyWith(
//                   fontWeight: FontWeight.w600,
//                   fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 16,
//                 ),
//               ),
//               Text(
//                 subTitle,
//                 style: poppinsSemiBold.copyWith(
//                   fontWeight: FontWeight.w400,
//                   fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 11,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 8),
//         const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16)
//       ],
//     );
//   }
// }
//
// class _SelectedPaymentView extends StatelessWidget {
//   const _SelectedPaymentView({
//     required this.total,
//   });
//
//   final double total;
//
//   @override
//   Widget build(BuildContext context) {
//     final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
//     final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);
//
//     return Container(
//       decoration: ResponsiveHelper.isDesktop(context)
//           ? BoxDecoration(
//               borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
//               color: Theme.of(context).cardColor,
//               border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.3), width: 1),
//             )
//           : const BoxDecoration(),
//       padding: EdgeInsets.symmetric(
//         vertical: Dimensions.paddingSizeSmall,
//         horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSizeDefault : 0,
//       ),
//       child: Column(children: [
//         Row(children: [
//           orderProvider.selectedPaymentMethod?.type == 'online'
//               ? CustomImageWidget(
//                   height: Dimensions.paddingSizeLarge,
//                   image: '${configModel.baseUrls?.getWayImageUrl}/${orderProvider.paymentMethod?.getWayImage}',
//                 )
//               : CustomAssetImageWidget(
//                   orderProvider.selectedPaymentMethod?.type == 'cash_on_delivery' ? Images.cashOnDelivery : Images.wallet,
//                   width: 20,
//                   height: 20,
//                   color: Theme.of(context).primaryColor,
//                 ),
//           const SizedBox(width: Dimensions.paddingSizeSmall),
//           Expanded(
//               child: Text(
//             '${orderProvider.selectedPaymentMethod?.getWayTitle}',
//             style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
//           )),
//           Text(
//             PriceConverterHelper.convertPrice(context, total),
//             textDirection: TextDirection.ltr,
//             style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
//           )
//         ]),
//       ]),
//     );
//   }
// }
