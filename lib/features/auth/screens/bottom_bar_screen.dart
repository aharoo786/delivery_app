import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/auth/screens/profile_screen.dart';
import 'package:flutter_grocery/features/cart/screens/cart_screen.dart';
import 'package:flutter_grocery/features/home/screens/home_screens.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/custom_image_widget.dart';
import '../../../utill/images.dart';
import '../../category/screens/all_categories_screen.dart';
import '../../order/screens/order_list_screen.dart';
import '../../profile/providers/profile_provider.dart';
import '../../splash/providers/splash_provider.dart';
import '../providers/auth_provider.dart';

class BottomBarScreen extends StatefulWidget {
  int? index;

  BottomBarScreen({Key? key, this.index = 0}) : super(key: key);

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  late bool _isLoggedIn;

  @override
  void initState() {
    _isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

    if (_isLoggedIn) {
      Provider.of<ProfileProvider>(context, listen: false)
          .getUserInfo(true, isUpdate: true);
    }
    super.initState();
  }

  final List<Widget> _widgetOption = [
    HomeScreen(),
    AllCategoriesScreen(),
    CartScreen(),
    OrderListScreen(),
    AccountScreen()
    //Container()
  ];

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);

    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: _widgetOption.elementAt(widget.index!),
      bottomNavigationBar: Container(
        height: 86,
        width: MediaQuery.of(context).size.width,
        //margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor:
                Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            currentIndex: widget.index!,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: const Color(0xff838383),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).primaryColor,
            ),
            unselectedIconTheme: const IconThemeData(
              color: Color(0xff838383),
            ),
            items: [
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    Images.homeIcon,
                    colorFilter: const ColorFilter.mode(
                        Color(0xff838383), BlendMode.srcIn),
                  ),
                  activeIcon: SvgPicture.asset(
                    Images.homeIcon,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).primaryColor, BlendMode.srcIn),
                  ),
                  label: "Home"),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(Images.cartIconBottom),
                  activeIcon: SvgPicture.asset(
                    Images.cartIconBottom,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).primaryColor, BlendMode.srcIn),
                  ),
                  label: "Categories"),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(Images.cartIconBottom),
                  activeIcon: SvgPicture.asset(
                    Images.cartIconBottom,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).primaryColor, BlendMode.srcIn),
                  ),
                  label: "Cart"),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    Images.orderIcon,
                  ),
                  activeIcon: SvgPicture.asset(
                    Images.orderIcon,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).primaryColor, BlendMode.srcIn),
                  ),
                  label: "My Order"),
              BottomNavigationBarItem(
                  icon: _isLoggedIn
                      ? getUserLoginImage(splashProvider)
                      : SvgPicture.asset(
                          Images.userIconBottom,
                        ),
                  activeIcon: _isLoggedIn
                      ? getUserLoginImage(splashProvider)
                      : SvgPicture.asset(
                          Images.userIconBottom,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).primaryColor, BlendMode.srcIn),
                        ),
                  label: _isLoggedIn ? "" : "Account"),
            ],
            onTap: (value) async {
              Provider.of<SplashProvider>(context, listen: false).bottomBarIndex = value;
              setState(() {
                widget.index = value;
              });
            },
          ),
        ),
      ),
    );
  }

  getUserLoginImage(SplashProvider splashProvider) {
    return Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
      return Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 22,
                offset: const Offset(0, 8.8))
          ],
        ),
        child: ClipOval(
            child: CustomImageWidget(
          placeholder: Images.placeHolder,
          height: 40,
          width: 40,
          fit: BoxFit.cover,
          image:
              '${splashProvider.baseUrls?.customerImageUrl}/${profileProvider.userInfoModel?.image}',
        )),
      );
    });
  }
}
