import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/app_bar_base_widget.dart';
import 'package:flutter_grocery/common/widgets/not_login_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/order/widgets/order_widget.dart';
import 'package:provider/provider.dart';

import '../../../utill/color_resources.dart';
import '../../../utill/images.dart';
import 'order_details_screen.dart';

class OrderListScreen extends StatefulWidget {
  bool showAppBar;
   OrderListScreen({super.key,this.showAppBar=false});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    final bool isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    Provider.of<OrderProvider>(context, listen: false)
        .changeActiveOrderStatus(true, isUpdate: false);

    if (isLoggedIn) {
      _tabController = TabController(
          length: 2,
          initialIndex: 0,
          vsync: this,
          animationDuration: const Duration(milliseconds: 100));
      Provider.of<OrderProvider>(context, listen: false).getOrderList(context);
    }

    _tabController?.addListener(() {
      setState(() {
        final OrderProvider orderProvider =
            Provider.of<OrderProvider>(context, listen: false);
        orderProvider.changeActiveOrderStatus(_tabController?.index == 0);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

    // return  Scaffold(
    //   appBar: ResponsiveHelper.isMobilePhone() ? null: (ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget()) : const AppBarBaseWidget()) as PreferredSizeWidget?,
    //
    //   body: Padding(
    //     padding:  EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(
    //           'My Orders',
    //           style: poppinsSemiBold.copyWith(
    //             fontWeight: FontWeight.w600,
    //             fontSize:ResponsiveHelper.isDesktop(context)
    //                 ? Dimensions.fontSizeExtraLarge
    //                 : 28,),
    //         ),
    //         const SizedBox(height: Dimensions.paddingSizeExtraLarge),
    //
    //         Expanded(
    //           child: ListView.builder(
    //             shrinkWrap: true,
    //             physics: const BouncingScrollPhysics(),
    //             itemCount:12,
    //             padding: const EdgeInsets.symmetric(horizontal: 0),
    //             itemBuilder: (context, index) {
    //               // CategoryModel category = categoryProvider.categoryList![index];
    //               return InkWell(
    //                 onTap: () {
    //                 },
    //                 child: _myOrderListWidget(context:context),
    //                 // child: CategoryItemWidget(
    //                 //   title: "category.name",
    //                 //   icon: Images.fruit,
    //                 //   isSelected: false,
    //                 // ),
    //               );
    //             },
    //           ),
    //         ),
    //         const SizedBox(height: 12),
    //       ],
    //     ),
    //   ),
    // );

    return Scaffold(
      appBar: ResponsiveHelper.isMobilePhone()
          ?  widget.showAppBar?AppBar(
        elevation: 0,
        scrolledUnderElevation: 0.0,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios_new,color: Colors.black,)),
      )  : null
          : (ResponsiveHelper.isDesktop(context)
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
              : const AppBarBaseWidget()) as PreferredSizeWidget?,
      body: isLoggedIn
          ? Consumer<OrderProvider>(builder: (context, orderProvider, child) {
              return Column(
                children: [
                  ResponsiveHelper.isDesktop(context)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeExtraLarge),
                          child: Text("my_orders".tr,
                              style: poppinsSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge)),
                        )
                      : const SizedBox(),
                  Center(
                    child: TabBar(
                      onTap: (int? index) =>
                          orderProvider.changeActiveOrderStatus(index == 0),
                      tabAlignment: TabAlignment.center,
                      controller: _tabController,
                      labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorWeight: 3,
                      unselectedLabelStyle: poppinsRegular.copyWith(
                          color: Theme.of(context).disabledColor,
                          fontSize: Dimensions.fontSizeSmall),
                      labelStyle: poppinsMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall),
                      tabs: [
                        Tab(text: getTranslated('ongoing', context)),
                        Tab(text: getTranslated('history', context)),
                      ],
                    ),
                  ),
                  Expanded(
                      child: TabBarView(
                    controller: _tabController,
                    children: const [
                      OrderWidget(isRunning: true),
                      OrderWidget(isRunning: false),
                    ],
                  )),
                ],
              );
            })
          : const NotLoggedInWidget(),
    );
  }

  _myOrderListWidget({context}) {
    return Container(
      width: 84,
      // height: 110,
      margin: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeExtraSmall, horizontal: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Theme.of(context).cardColor),
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
                Images.chicken,
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
                Text(
                  'Chicken Dum Biryani ',
                  style: poppinsSemiBold.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.fontSizeExtraLarge
                        : 14,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  'BTM Layout',
                  style: poppinsSemiBold.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.fontSizeExtraLarge
                        : 12,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text("13/2/23, 8:45PM",
                    style: poppinsSemiBold.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                SizedBox(
                  height: 4,
                ),
              ],
            ),
            Spacer(),
            Row(
              children: [
                Icon(
                  Icons.done,
                  color: Theme.of(context).primaryColor,
                  size: 16,
                ),
                SizedBox(width: 2),
                Text('Delivered',
                    style: poppinsSemiBold.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: ResponsiveHelper.isDesktop(context)
                            ? Dimensions.fontSizeExtraLarge
                            : 14,
                        color: Theme.of(context).primaryColor)),
              ],
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Row(
            children: [
              Text(
                '₹160 I  2 Items',
                style: poppinsSemiBold.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorResources.priceColor,
                  fontSize: 16,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                    return OrderDetailsScreen(
                      orderModel: null,
                      orderId: null,
                    );
                  }));
                },
                child: Text(
                  'View Details',
                  style: poppinsSemiBold.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 11,
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Divider(
            color: ColorResources.borderColor,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
      ),
    );
  }
}
