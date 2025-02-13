import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_pop_scope_widget.dart';
import 'package:flutter_grocery/features/menu/domain/models/custom_drawer_controller_model.dart';
import 'package:flutter_grocery/features/menu/domain/models/main_screen_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/features/address/providers/location_provider.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/common/providers/theme_provider.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/third_party_chat_widget.dart';
import 'package:flutter_grocery/features/home/screens/home_screens.dart';
import 'package:flutter_grocery/features/refer_and_earn/screens/refer_and_earn_screen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../profile/screens/profile_screen.dart';

// List<MainScreenModel> screenList = [
//   MainScreenModel(const HomeScreen(), 'home', Images.home),
//   MainScreenModel(const AllCategoriesScreen(), 'all_categories', Images.list),
//   MainScreenModel(const CartScreen(), 'shopping_bag', Images.orderBag),
//   MainScreenModel(const WishListScreen(), 'favourite', Images.favouriteIcon),
//   MainScreenModel(const OrderListScreen(), 'my_order', Images.orderList),
//   MainScreenModel(const OrderSearchScreen(), 'track_order', Images.orderDetails),
//   MainScreenModel(const AddressListScreen(), 'address', Images.location),
//   MainScreenModel(const CouponScreen(), 'coupon', Images.coupon),
//   MainScreenModel(const ChatScreen(orderModel: null,), 'live_chat', Images.chat),
//   MainScreenModel(const SettingsScreen(), 'settings', Images.settings),
//   if(Provider.of<SplashProvider>(Get.context!, listen: false).configModel?.walletStatus! ?? false)
//     MainScreenModel(const WalletScreen(), 'wallet', Images.wallet),
//   if(Provider.of<SplashProvider>(Get.context!, listen: false).configModel?.loyaltyPointStatus! ?? false)
//     MainScreenModel(const LoyaltyScreen(), 'loyalty_point', Images.loyaltyIcon),
//   MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.termsAndCondition), 'terms_and_condition', Images.termsAndConditions),
//   MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.privacyPolicy), 'privacy_policy', Images.privacyPolicy),
//   MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.aboutUs), 'about_us', Images.aboutUs),
//   if(Provider.of<SplashProvider>(Get.context!, listen: false).configModel?.returnPolicyStatus ?? false)
//     MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.returnPolicy), 'return_policy', Images.returnPolicy),
//
//   if(Provider.of<SplashProvider>(Get.context!, listen: false).configModel?.refundPolicyStatus ?? false)
//     MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.refundPolicy), 'refund_policy', Images.refundPolicy),
//
//   if(Provider.of<SplashProvider>(Get.context!, listen: false).configModel?.cancellationPolicyStatus ?? false)
//     MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.cancellationPolicy), 'cancellation_policy', Images.cancellationPolicy),
//
//   MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.faq), 'faq', Images.faq),
// ];

class MainScreen extends StatefulWidget {
  final bool isReload;
  final CustomDrawerController drawerController;
  const MainScreen(
      {super.key, required this.drawerController, this.isReload = true});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool canExit = kIsWeb;

  @override
  void initState() {
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);
    splashProvider.initializeScreenList();
    print("----------(INITIALIZED)----------${widget.isReload}");
    if (widget.isReload) {
      HomeScreen.loadData(true, context);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme =
        Provider.of<ThemeProvider>(context, listen: false).darkTheme;
    return Consumer<SplashProvider>(
      builder: (context, splash, child) {
        return CustomPopScopeWidget(
          child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
            final referMenu = MainScreenModel(const ReferAndEarnScreen(),
                'referAndEarn', Images.referralIcon);
            if ((splash.configModel?.referEarnStatus ?? false) &&
                profileProvider.userInfoModel?.referCode != null &&
                splash.screenList[9].title != 'referAndEarn') {
              splash.screenList
                  .removeWhere((menu) => menu.screen == referMenu.screen);
              splash.screenList.insert(9, referMenu);
            }

            return Consumer<LocationProvider>(
              builder: (context, locationProvider, child) => InkWell(
                onTap: () {
                  if (!ResponsiveHelper.isDesktop(context) &&
                      widget.drawerController.isOpen()) {
                    widget.drawerController.toggle();
                  }
                },
                child: Scaffold(
                  // floatingActionButton: !ResponsiveHelper.isDesktop(context)
                  //     ? Padding(
                  //         padding: const EdgeInsets.symmetric(vertical: 50.0),
                  //         child: ThirdPartyChatWidget(
                  //             configModel: splash.configModel),
                  //       )
                  //     : null,
                  appBar: ResponsiveHelper.isDesktop(context)
                      ? null
                      : PreferredSize(
                          preferredSize: Size.fromHeight(65),
                          child: AppBar(
                              backgroundColor: Theme.of(context).cardColor,
                              centerTitle: true,
                              elevation: 0,
                              scrolledUnderElevation: 0,
                              leading: Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Deliver Now",
                                      style: poppinsRegular.copyWith(
                                          color: Color(0xff868E96)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Consumer<LocationProvider>(
                                      builder: (BuildContext context, value,
                                          Widget? child) {
                                        return Row(
                                          children: [
                                            Text(
                                              value.address!.isEmpty
                                                  ? "Address.."
                                                  : value.address ?? "",
                                              style: poppinsSemiBold.copyWith(
                                                  fontSize: 20),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Icon(Icons
                                                .keyboard_arrow_down_rounded)
                                          ],
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ),
                              leadingWidth: 168,
                              actions: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        RouteHelper.profile,
                                        arguments: const ProfileScreen());
                                  },
                                  child: Container(
                                    height: 48,
                                    width: 48,
                                    margin: EdgeInsets.only(right: 16),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xffF2F2F3)),
                                    child: SvgPicture.asset(
                                      Images.userIconBottom,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              ]),
                        ),
                  body: splash.screenList[splash.pageIndex].screen,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
