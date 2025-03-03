import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/features/cart/screens/coupon_screen.dart';
import 'package:flutter_grocery/features/cart/widgets/cart_button_widget.dart';
import 'package:flutter_grocery/features/cart/widgets/cart_product_list_widget.dart';
import 'package:flutter_grocery/helper/cart_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/features/coupon/providers/coupon_provider.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/common/widgets/app_bar_base_widget.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/no_data_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:provider/provider.dart';

import '../../../common/models/config_model.dart';
import '../../../common/providers/localization_provider.dart';
import '../../../common/providers/product_provider.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../common/widgets/custom_shadow_widget.dart';
import '../../../common/widgets/custom_single_child_list_widget.dart';
import '../../../common/widgets/title_widget.dart';
import '../../../helper/date_converter_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../utill/color_resources.dart';
import '../../../utill/product_type.dart';
import '../../../utill/styles.dart';
import '../../home/widgets/home_item_widget.dart';
import '../widgets/cart_details_widget.dart';
import '../widgets/delivery_option_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    _couponController.clear();
    Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
    Provider.of<OrderProvider>(context, listen: false).setOrderType('delivery', notify: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      productProvider.getItemList(1, isUpdate: false, productType: ProductType.dailyItem);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
    final CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: ResponsiveHelper.isMobilePhone()
          ? null
          : (ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget()) : const AppBarBaseWidget())
              as PreferredSizeWidget?,
      body: Center(
        child: Consumer<CouponProvider>(builder: (context, couponProvider, _) {
          return Consumer<CartProvider>(
            builder: (context, cart, child) {
              double itemPrice = 0;
              double discount = 0;
              double tax = 0;

              for (var cartModel in cart.cartList) {
                itemPrice = itemPrice + (cartModel.price! * cartModel.quantity!);
                discount = discount + (cartModel.discount! * cartModel.quantity!);
                tax = tax + (cartModel.tax! * cartModel.quantity!);
              }

              double subTotal = itemPrice + (configModel.isVatTexInclude! ? 0 : tax);
              bool isFreeDelivery = subTotal >= configModel.freeDeliveryOverAmount! && configModel.freeDeliveryStatus! || couponProvider.coupon?.couponType == 'free_delivery';

              double total = subTotal - discount - Provider.of<CouponProvider>(context).discount!;

              double weight = 0.0;
              weight = CartHelper.weightCalculation(cartProvider.cartList);

              return cart.cartList.isNotEmpty
                  ? !ResponsiveHelper.isDesktop(context)
                      ? Column(children: [
                          Expanded(
                              child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: Dimensions.paddingSizeSmall,
                            ),
                            child: Center(
                                child: SizedBox(
                              width: Dimensions.webScreenWidth,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                // Product
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Cart',
                                      style: poppinsBold.copyWith(
                                        fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 20,
                                      ),
                                    ),
                                    Text(
                                      '${cart.cartList.length} Items',
                                      style: poppinsMedium.copyWith(
                                        fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const CartProductListWidget(),
                                const SizedBox(height: Dimensions.paddingSizeDefault),
                                const Divider(color: ColorResources.borderColor),
                                Consumer<ProductProvider>(builder: (context, productProvider, child) {
                                  bool isDalyProduct = (productProvider.dailyProductModel == null || (productProvider.dailyProductModel?.products?.isNotEmpty ?? false));

                                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(
                                      'Delivery Options',
                                      style: poppinsSemiBold.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 16,
                                      ),
                                    ),
                                    HomeItemWidget(productList: productProvider.dailyProductModel?.products),
                                  ]);
                                }),
                                const SizedBox(height: Dimensions.paddingSizeDefault),
                                const Divider(color: ColorResources.borderColor),
                                const SizedBox(height: Dimensions.paddingSizeDefault),
                                if (cart.isShowScheduleTime)
                                  // Time Slot
                                  Consumer<OrderProvider>(builder: (context, orderProvider, child) {
                                    return CustomShadowWidget(
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
                                                        color:
                                                            index == orderProvider.selectDateSlot ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
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
                                                              Icon(Icons.history,
                                                                  color: orderProvider.selectTimeSlot == index ? Theme.of(context).cardColor : Theme.of(context).disabledColor,
                                                                  size: 20),
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
                                    );
                                  }),

                                const Divider(
                                  color: ColorResources.borderColor,
                                ),
                                const SizedBox(height: Dimensions.paddingSizeDefault),
                                Consumer<CouponProvider>(builder: (context, couponProvider, child) {
                                  return GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Rounded top corners
                                        ),
                                        backgroundColor: Colors.transparent, // Important: Makes sure the background is clear
                                        builder: (context) {
                                          return SizedBox(
                                            height: MediaQuery.of(context).size.height * 0.6,
                                            width: double.maxFinite,
                                            child: ClipRRect(
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), // Ensure modal is clipped
                                                child: CouponScreen(subTotal: subTotal, comesFromCart: true)),
                                          );
                                        },
                                      );
                                    },
                                    child: _cartScreenWidget(
                                        context: context,
                                        icon: Images.promocode,
                                        isImage: true,
                                        text: couponProvider.coupon != null ? "Promo Code Applied" : "Apply Promo Code",
                                        subTitle: couponProvider.coupon != null ? '  You save ${couponProvider.coupon?.discount ?? 0.0}' : "No discount",
                                        promoCodeText: couponProvider.coupon != null ? couponProvider.coupon?.code ?? '' : "",
                                        isPromoCode: true),
                                  );
                                }),

                                const SizedBox(height: Dimensions.paddingSizeDefault),

                                const Divider(
                                  color: ColorResources.borderColor,
                                ),
                                const SizedBox(height: Dimensions.paddingSizeDefault),
                                Text(
                                  'Delivery Options',
                                  style: poppinsSemiBold.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 16,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: DeliveryOptionWidget(
                                          value: 'delivery',
                                          title: getTranslated('home_delivery', context),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      if (configModel.selfPickup == 1)
                                        Expanded(
                                          child: DeliveryOptionWidget(
                                            value: 'self_pickup',
                                            title: getTranslated('self_pickup', context),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: Dimensions.paddingSizeDefault),
                                const Divider(
                                  color: ColorResources.borderColor,
                                ),
                                const SizedBox(height: Dimensions.paddingSizeDefault),
                                CartDetailsWidget(
                                    couponController: _couponController, total: total, isFreeDelivery: isFreeDelivery, itemPrice: itemPrice, tax: tax, discount: discount),
                                const SizedBox(height: 40),
                              ]),
                            )),
                          )),
                          CartButtonWidget(
                            subTotal: subTotal,
                            configModel: configModel,
                            itemPrice: itemPrice,
                            total: total,
                            isFreeDelivery: isFreeDelivery,
                            discount: discount,
                            tax: tax,
                            weight: weight,
                          ),
                        ])
                      : CustomScrollView(slivers: [
                          SliverToBoxAdapter(
                            child: Center(
                                child: SizedBox(
                                    width: Dimensions.webScreenWidth,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              flex: 6,
                                              child: Container(
                                                padding: const EdgeInsets.only(
                                                  left: Dimensions.paddingSizeLarge,
                                                  right: Dimensions.paddingSizeLarge,
                                                  top: Dimensions.paddingSizeLarge,
                                                  bottom: Dimensions.paddingSizeSmall,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).cardColor,
                                                  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSizeDefault)),
                                                  boxShadow: [
                                                    BoxShadow(color: Colors.grey.withOpacity(0.01), spreadRadius: 1, blurRadius: 1),
                                                  ],
                                                ),
                                                child: const CartProductListWidget(),
                                              )),
                                          const SizedBox(width: Dimensions.paddingSizeLarge),
                                          Expanded(
                                              flex: 4,
                                              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                                                CartDetailsWidget(
                                                  couponController: _couponController,
                                                  total: total,
                                                  isFreeDelivery: isFreeDelivery,
                                                  itemPrice: itemPrice,
                                                  tax: tax,
                                                  discount: discount,
                                                ),
                                                const SizedBox(height: Dimensions.paddingSizeLarge),
                                                CartButtonWidget(
                                                  subTotal: subTotal,
                                                  configModel: configModel,
                                                  itemPrice: itemPrice,
                                                  total: total,
                                                  isFreeDelivery: isFreeDelivery,
                                                  discount: discount,
                                                  tax: tax,
                                                  weight: weight,
                                                ),
                                              ]))
                                        ],
                                      ),
                                    ))),
                          ),
                          const FooterWebWidget(footerType: FooterType.sliver),
                        ])
                  : NoDataWidget(image: Images.favouriteNoDataImage, title: getTranslated('empty_shopping_bag', context));
            },
          );
        }),
      ),
    );
  }

  _tipContainer({context, text}) {
    return Container(
        width: 70,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
        // alignment: Alignment.center,
        // margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                //DEE2E6
                color: ColorResources.borderColor,
                width: 1)),
        child: Center(
          child: Text(
            text,
            style: poppinsRegular.copyWith(color: Colors.black, fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w500
                // color: categoryProvider.selectedCategoryIndex == -1 ? Theme.of(context).canvasColor : Colors.black ,
                ),
          ),
        ));
  }

  Widget _cartScreenWidget({context, icon, text, subTitle, isImage, promoCodeText = '', isPromoCode = false, isNotFromDeliveryInstructions = true}) {
    return Row(
      children: [
        isImage
            ? Image.asset(
                icon,
                height: 20,
              )
            : Icon(
                icon,
                color: Colors.black,
                size: 20,
              ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: poppinsSemiBold.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 16,
                ),
              ),
              isPromoCode
                  ? Row(
                      children: [
                        Text(
                          promoCodeText,
                          style: poppinsSemiBold.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                            fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subTitle,
                          style: poppinsSemiBold.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    )
                  : Text(
                      subTitle,
                      style: poppinsSemiBold.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          isNotFromDeliveryInstructions
              ? Icons.arrow_forward_ios
              : Provider.of<CartProvider>(context).isDeliveryInstructionOpen
                  ? Icons.keyboard_arrow_down
                  : Icons.arrow_forward_ios,
          color: Colors.black,
          size: 16,
        )
      ],
    );
  }
}
