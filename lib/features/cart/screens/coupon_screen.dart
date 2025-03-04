import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_grocery/features/coupon/providers/coupon_provider.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/custom_image_widget.dart';
import '../../../common/widgets/custom_text_field_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/color_resources.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../../category/widgets/category_item_widget.dart';
import '../../coupon/domain/models/coupon_model.dart';
import '../../splash/providers/splash_provider.dart';

class CouponScreen extends StatefulWidget {
  final double subTotal;
  final bool comesFromCart;
  CouponScreen({super.key, this.subTotal = 0.0, this.comesFromCart = false});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  final TextEditingController _coupon = TextEditingController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<CouponProvider>(context, listen: false).getCouponList(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
          : widget.comesFromCart
              ? AppBar(
                  backgroundColor: Colors.white,
                  scrolledUnderElevation: 0.0,
                  leading: const SizedBox.shrink(),
                  title: const Icon(Icons.keyboard_arrow_down),
                  centerTitle: true, // Ensures centering
                )
              : AppBar(
                  backgroundColor: Colors.white,
                  scrolledUnderElevation: 0.0,
                  leading: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.black)),
                )),
      body: Consumer<CouponProvider>(builder: (context, couponProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 15),
              Text(
                'Coupons',
                style: poppinsSemiBold.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 28,
                ),
              ),
              Container(
                // color: Colors.red,
                color: Theme.of(context).disabledColor.withOpacity(0.001),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextFieldWidget(
                        fillColor: Theme.of(context).disabledColor.withOpacity(0.001),
                        hintText: 'Type coupon code',
                        showOneSideBorerRadius: true,
                        isShowBorder: false,
                        prefixAssetImageColor: Colors.black,
                        isShowPrefixIcon: false,
                        prefixAssetUrl: Images.search,
                        controller: _coupon,
                        inputAction: TextInputAction.search,
                        isIcon: true,
                        onSubmit: (text) async {
                          await couponProvider.applyCoupon(text, widget.subTotal);
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await couponProvider.applyCoupon(_coupon.text, widget.subTotal);
                      },
                      child: Container(
                        width: 70,
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(0.0),
                                bottomLeft: const Radius.circular(0.0),
                                topRight: Radius.circular(ResponsiveHelper.isDesktop(context) ? 20 : 12),
                                bottomRight: Radius.circular(ResponsiveHelper.isDesktop(context) ? 20 : 12))),
                        child: Center(
                          child: Text('Apply', style: poppinsRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Available coupon',
                style: poppinsSemiBold.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 18,
                ),
              ),
              // const SizedBox(height: 24),
              (couponProvider.couponList != null && (couponProvider.couponList?.isNotEmpty ?? false))
                  ? Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: couponProvider.couponList?.length ?? 0,
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        itemBuilder: (context, index) {
                          CouponModel coupon = couponProvider.couponList![index];
                          return GestureDetector(
                            onTap: () async {
                              if (coupon.code != null) {
                                await couponProvider.applyCoupon(coupon.code ?? '', widget.subTotal);
                              }

                              print(coupon.discountType);
                            },
                            child: _searchScreenCategoryWidget(context: context, coupon: coupon, couponProvider: couponProvider),
                          );
                        },
                      ),
                    )
                  : const Center(child: Text('Coupons are not available')),
              const SizedBox(height: 12),
            ],
          ),
        );
      }),
    );
  }

  _searchScreenCategoryWidget({context, required CouponModel coupon, required CouponProvider couponProvider}) {
    return Container(
      width: 84,
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: Theme.of(context).cardColor),
      child: Column(
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: 60,
              width: 60,
              alignment: Alignment.center,
              //padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      //DEE2E6
                      color: ColorResources.borderColor,
                      width: 1)),
              child: Image.asset(
                Images.mycoupon,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // width: 100,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    coupon.code ?? '',
                    style: poppinsSemiBold.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 11,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                    // "40% OFF up to 2265",
                    '${coupon.discount} OFF up to ${widget.subTotal}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: poppinsSemiBold.copyWith(fontWeight: FontWeight.w500, fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Text(
                      'View Details',
                      style: poppinsSemiBold.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_outlined,
                      size: 11,
                    ),
                  ],
                )
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                if (coupon.code != null) {
                  await couponProvider.applyCoupon(coupon.code ?? '', widget.subTotal);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Text('Apply',
                    style: poppinsSemiBold.copyWith(
                        fontWeight: FontWeight.w600, fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 14, color: Theme.of(context).primaryColor)),
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          const Divider(
            color: ColorResources.borderColor,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
      ),
    );
  }
}
