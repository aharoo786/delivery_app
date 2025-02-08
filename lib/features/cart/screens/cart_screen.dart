import 'package:flutter/material.dart';
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

import '../../../utill/color_resources.dart';
import '../../../utill/styles.dart';
import '../widgets/cart_details_widget.dart';

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


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
    final CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);


    return Scaffold(
      appBar: ResponsiveHelper.isMobilePhone() ? null: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget()) : const AppBarBaseWidget()) as PreferredSizeWidget?,
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
                    ? !ResponsiveHelper.isDesktop(context) ? Column(children: [
                      Expanded(child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        child: Center(child: SizedBox(width: Dimensions.webScreenWidth, child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          // Product

                            const SizedBox(height: 24),
                            Text(
                              'Cart',
                              style: poppinsSemiBold.copyWith(
                                fontSize:ResponsiveHelper.isDesktop(context)
                                    ? Dimensions.fontSizeExtraLarge
                                    : 20,),
                            ),
                            const SizedBox(height: 16),

                            _cartScreenWidget(
                              context: context,
                              icon: Icons.location_on_outlined,
                              isImage: false,
                              text: "Delivery Address",
                              subTitle: '12th Main Road, Sector 6, HSR Layout, Bengaluru, Karnataka,...'
                            ),

                            const SizedBox(height: 56),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Items in your cart',
                                  style: poppinsSemiBold.copyWith(
                                    fontSize:ResponsiveHelper.isDesktop(context)
                                        ? Dimensions.fontSizeExtraLarge
                                        : 20,),
                                ),
                                Text(
                                  '+ Add More',
                                  style: poppinsSemiBold.copyWith(
                                    fontWeight: FontWeight.w600,
                                      fontSize:ResponsiveHelper.isDesktop(context)
                                          ? Dimensions.fontSizeExtraLarge
                                          : 14,
                                      color: Theme.of(context).primaryColor
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),





                            const CartProductListWidget(),
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                          Container(
                              height: 50,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeDefault ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).disabledColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),child:  Text(
                            'Add Cooking Instruction',
                            style: poppinsSemiBold.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize:ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.fontSizeExtraLarge
                                  : 14,),
                          ),),
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                            Text('Delivery Time', style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 150,
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
                                 // alignment: Alignment.center,
                                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(//DEE2E6
                                          color: Colors.black,
                                          width: 1)
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        Images.clock,
                                        height: 20,
                                        width: 20,
                                      ),
                                      SizedBox(width: 8,),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Standard',
                                            style: poppinsRegular.copyWith(
                                              color:Colors.black ,
                                             fontSize: Dimensions.fontSizeDefault,
                                             fontWeight: FontWeight.w600
                                             // color: categoryProvider.selectedCategoryIndex == -1 ? Theme.of(context).canvasColor : Colors.black ,
                                            ),
                                          ),
                                          Text(
                                            '20-30 Mins',
                                            style: poppinsRegular.copyWith(
                                              color:Colors.black ,
                                              fontWeight: FontWeight.w400,
                                              fontSize: Dimensions.fontSizeSmall
                                              // color: categoryProvider.selectedCategoryIndex == -1 ? Theme.of(context).canvasColor : Colors.black ,
                                            ),
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),
                                ), Container(
                                  width: 150,
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
                                 // alignment: Alignment.center,
                                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(//DEE2E6
                                          color: ColorResources.borderColor,
                                          width: 1)
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        Images.dateIcon,
                                        height: 20,
                                        width: 20,
                                      ),
                                      SizedBox(width: 8,),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Schedule',
                                            style: poppinsRegular.copyWith(
                                              color:Colors.black ,
                                             fontSize: Dimensions.fontSizeDefault,
                                             fontWeight: FontWeight.w600
                                             // color: categoryProvider.selectedCategoryIndex == -1 ? Theme.of(context).canvasColor : Colors.black ,
                                            ),
                                          ),
                                          Text(
                                            'Select Time',
                                            style: poppinsRegular.copyWith(
                                              color:Colors.black ,
                                              fontWeight: FontWeight.w400,
                                              fontSize: Dimensions.fontSizeSmall
                                              // color: categoryProvider.selectedCategoryIndex == -1 ? Theme.of(context).canvasColor : Colors.black ,
                                            ),
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            Divider(color: ColorResources.borderColor,),
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                            _cartScreenWidget(
                                context: context,
                                icon: Images.instruction,
                                isImage: true,
                                text: "Delivery Instructions",
                                subTitle: 'Leave At Door'
                            ),
                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            Divider(color: ColorResources.borderColor,),
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                            _cartScreenWidget(
                                context: context,
                                icon: Images.instruction,
                                isImage: true,
                                text: "Gift someone else",
                                subTitle: 'Add person info & message'
                            ),
                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            Divider(color: ColorResources.borderColor,),
                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (ctx){
                                  return CouponScreen();
                                }));
                              },
                              child:  _cartScreenWidget(
                                  context: context,
                                  icon: Images.promocode,
                                  isImage: true,
                                  text: "Promo Code Applied",
                                  subTitle: '₹85 coupon savings ',
                                  promoCodeText: "PAYTMCC120 ",
                                  isPromoCode: true
                              ),

                            ),

                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            Divider(color: ColorResources.borderColor,),
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                            Text('Add Tip', style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                               _tipContainer(context: context,text: "₹20"),
                               _tipContainer(context: context,text: "₹30"),
                               _tipContainer(context: context,text: "₹50"),
                               _tipContainer(context: context,text: "Custom"),
                              ],
                            ),
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                            CartDetailsWidget(
                            couponController: _couponController, total: total,
                            isFreeDelivery: isFreeDelivery,
                            itemPrice: itemPrice, tax: tax,
                            discount: discount),
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
                        child: Center(child: SizedBox(width: Dimensions.webScreenWidth, child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Expanded(flex: 6, child: Container(
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

                              Expanded(flex:4, child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

                                CartDetailsWidget(
                                  couponController: _couponController,
                                  total: total,
                                  isFreeDelivery: isFreeDelivery,
                                  itemPrice: itemPrice, tax: tax,
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

                ]) :  NoDataWidget(image: Images.favouriteNoDataImage, title: getTranslated('empty_shopping_bag', context));
              },
            );
          }
        ),
      ),
    );
  }

  _tipContainer({context,text}){
    return Container(
        width: 70,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
        // alignment: Alignment.center,
       // margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(//DEE2E6
                color: ColorResources.borderColor,
                width: 1)
        ),
        child: Center(
          child:  Text(
            text,
            style: poppinsRegular.copyWith(
                color:Colors.black ,
                fontSize: Dimensions.fontSizeDefault,
                fontWeight: FontWeight.w500
              // color: categoryProvider.selectedCategoryIndex == -1 ? Theme.of(context).canvasColor : Colors.black ,
            ),
          ),
        )
    );
  }

  _cartScreenWidget({context,icon,text,subTitle,isImage,promoCodeText='',isPromoCode=false}){
    return      Row(
      children: [
        isImage?
        Image.asset(icon,height: 20,):
        Icon(icon,color: Colors.black,size: 20,),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: poppinsSemiBold.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize:ResponsiveHelper.isDesktop(context)
                      ? Dimensions.fontSizeExtraLarge
                      : 16,),
              ),
              isPromoCode?
              Row(
                children: [
                  Text(
                    promoCodeText,
                    style: poppinsSemiBold.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                      fontSize:ResponsiveHelper.isDesktop(context)
                          ? Dimensions.fontSizeExtraLarge
                          : 11,),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subTitle,
                    style: poppinsSemiBold.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize:ResponsiveHelper.isDesktop(context)
                          ? Dimensions.fontSizeExtraLarge
                          : 11,),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ):
              Text(
                subTitle,
                style: poppinsSemiBold.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize:ResponsiveHelper.isDesktop(context)
                      ? Dimensions.fontSizeExtraLarge
                      : 11,),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.arrow_forward_ios,color: Colors.black,size: 16,)
      ],
    );
  }
}






