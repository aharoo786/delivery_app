import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../common/enums/html_type_enum.dart';
import '../../../common/widgets/custom_image_widget.dart';
import '../../../common/widgets/not_login_widget.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../address/screens/address_list_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../cart/screens/coupon_screen.dart';
import '../../chat/screens/chat_screen.dart';
import '../../html/screens/html_viewer_screen.dart';
import '../../menu/screens/setting_screen.dart';
import '../../menu/widgets/sign_out_dialog_widget.dart';
import '../../order/screens/order_list_screen.dart';
import '../../order/screens/order_search_screen.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/widgets/profile_details_widget.dart';
import '../../profile/widgets/profile_header_widget.dart';
import '../../refer_and_earn/screens/refer_and_earn_screen.dart';
import '../../wallet_and_loyalty/screens/loyalty_screen.dart';
import '../../wallet_and_loyalty/screens/wallet_screen.dart';
import '../../wishlist/screens/wishlist_screen.dart';
import '../providers/auth_provider.dart';

class AccountScreen extends StatefulWidget {
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();

    _isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

    if (_isLoggedIn) {
      Provider.of<ProfileProvider>(context, listen: false)
          .getUserInfo(true, isUpdate: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   scrolledUnderElevation: 0.0,
      //   leading: IconButton(onPressed: (){
      //
      //   }, icon: Icon(Icons.arrow_back_ios_new,color: Colors.black,)),
      // ),
      body: !_isLoggedIn
          ? const NotLoggedInWidget()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Center(
                    child: Column(
                      children: [
                        _isLoggedIn
                            ? Consumer<ProfileProvider>(
                                builder: (context, profileProvider, child) {
                                return profileProvider.userInfoModel == null
                                    ? const SizedBox.shrink()
                                    : Column(
                                        children: [
                                          // ProfileHeaderWidget(),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${profileProvider.userInfoModel?.fName ?? ''} ${profileProvider.userInfoModel?.lName ?? ''}',
                                                      style: poppinsMedium.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: Dimensions
                                                              .fontSizeOverLarge),
                                                    ),
                                                    Text(
                                                      profileProvider
                                                              .userInfoModel!
                                                              .phone ??
                                                          '',
                                                      style: poppinsRegular.copyWith(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: Dimensions
                                                              .fontSizeDefault),
                                                    ),
                                                  ],
                                                ),
                                                // GestureDetector(
                                                //   onTap: () {
                                                //     Navigator.of(context).pushNamed(RouteHelper.profile, arguments: const ProfileScreen());
                                                //   },
                                                //   child: Container(
                                                //     height: 48,
                                                //     width: 48,
                                                //     margin: const EdgeInsets.only(right: 16),
                                                //     padding: const EdgeInsets.all(10),
                                                //     decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffF2F2F3)),
                                                //     child: SvgPicture.asset(
                                                //       Images.userIconBottom,
                                                //       color: Colors.black,
                                                //     ),
                                                //   ),
                                                // )
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                              })
                            : const NotLoggedInWidget(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  AccountOption(
                    isImg: true,
                    svgPath: Images.myAccount,
                    icon: Icons.person_outline,
                    title: 'My Account',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return const ProfileScreen();
                      }));
                    },
                  ),
                  AccountOption(
                    isImg: true,
                    svgPath: Images.myOrder,
                    icon: Icons.person_outline,
                    title: 'My order',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return OrderListScreen(
                          showAppBar: true,
                        );
                      }));
                    },
                  ),
                  AccountOption(
                    isImg: true,
                    svgPath: Images.myPayment,
                    icon: Icons.settings_outlined,
                    title: 'Payment',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return WalletScreen(
                          showAppBar: true,
                        );
                      }));
                    },
                  ),
                  AccountOption(
                    isImg: true,
                    svgPath: Images.myAddress,
                    icon: Icons.settings_outlined,
                    title: 'Address',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return AddressListScreen(
                          showAppBar: true,
                        );
                      }));
                    },
                  ),
                  AccountOption(
                    isImg: true,
                    svgPath: Images.myFav,
                    icon: Icons.settings_outlined,
                    title: 'Favourites',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return const WishListScreen();
                      }));
                    },
                  ),
                  AccountOption(
                    isImg: false,
                    svgPath: Images.loyaltyPoint,
                    icon: Icons.loyalty,
                    title: getTranslated('loyalty_point', context),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return const LoyaltyScreen();
                      }));
                    },
                  ),
                  AccountOption(
                    isImg: true,
                    svgPath: Images.referralIcon,
                    icon: Icons.settings_outlined,
                    title: getTranslated('referAndEarn', context),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return const ReferAndEarnScreen();
                      }));
                    },
                  ),
                  AccountOption(
                    isImg: true,
                    svgPath: Images.myPromoCode,
                    icon: Icons.settings_outlined,
                    title: 'Promo Codes',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return CouponScreen();
                      }));
                    },
                  ),
                  AccountOption(
                    isImg: true,
                    svgPath: Images.mySettings,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return const SettingsScreen();
                      }));
                    },
                  ),

                  AccountOption(
                    isImg: true,
                    svgPath: Images.myHelp,
                    icon: Icons.info_outline,
                    title: getTranslated('terms_and_condition', context),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return const HtmlViewerScreen(
                            htmlType: HtmlType.termsAndCondition);
                      }));
                    },
                  ),
                  AccountOption(
                    isImg: true,
                    svgPath: Images.myHelp,
                    icon: Icons.info_outline,
                    title: 'About us',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return const HtmlViewerScreen(
                            htmlType: HtmlType.aboutUs);
                      }));
                    },
                  ),
                  AccountOption(
                    isImg: true,
                    svgPath: Images.myHelp,
                    icon: Icons.info_outline,
                    title: 'Help',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return const HtmlViewerScreen(
                            htmlType: HtmlType.aboutUs);
                      }));
                    },
                  ),

                  AccountOption(
                    icon: Icons.logout,
                    title: 'Log Out',
                    iconColor: Theme.of(context).colorScheme.error,
                    onTap: () {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const SignOutDialogWidget());
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 18),
      child: Text(
        title,
        style: poppinsMedium.copyWith(
          fontSize: 16,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class AccountOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? svgPath;
  final Widget? trailing;
  final Color? iconColor;
  final bool isSvg;
  final bool isImg;
  final Function()? onTap;

  const AccountOption(
      {super.key,
      required this.icon,
      required this.title,
      this.trailing,
      this.iconColor,
      this.onTap,
      this.isSvg = false,
      this.svgPath,
      this.isImg = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        onTap: onTap,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        leading: isImg
            ? Image.asset(
                svgPath!,
                color: Colors.black,
                height: 20,
                width: 20,
              )
            : isSvg
                ? SvgPicture.asset(
                    svgPath!,
                    height: 20,
                    width: 20,
                  )
                : Icon(
                    icon,
                    color: iconColor ??
                        Theme.of(context).textTheme.bodyMedium?.color,
                    size: 20,
                  ),
        title: Text(title,
            style: poppinsMedium.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            )),
        trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black,
            ) ??
            const SizedBox.shrink(),
      ),
    );
  }
}

class SwitchOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final Function()? onTap;

  const SwitchOption({
    super.key,
    required this.icon,
    this.onTap,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.only(left: 20, right: 10),
      visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
      leading: Icon(icon, color: Theme.of(context).textTheme.bodyMedium?.color),
      title: Text(title, style: poppinsMedium.copyWith(fontSize: 14)),
      trailing: Transform.scale(
        scale: 0.7,
        child: Switch(
          value: value,
          activeTrackColor: const Color(0xff40C979),
          inactiveTrackColor: Colors.grey,
          thumbColor:
              WidgetStateProperty.all(Theme.of(context).secondaryHeaderColor),
          onChanged: (bool newValue) {},
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }
}
