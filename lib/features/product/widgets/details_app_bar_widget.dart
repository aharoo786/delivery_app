import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/features/menu/screens/menu_screen.dart';
import 'package:provider/provider.dart';

import '../../cart/screens/cart_screen.dart';

class DetailsAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  const DetailsAppBarWidget({super.key, this.title});


  @override
  DetailsAppBarWidgetState createState() => DetailsAppBarWidgetState();

  @override
  Size get preferredSize => const Size(double.maxFinite, 50);
}

class DetailsAppBarWidgetState extends State<DetailsAppBarWidget> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
  }

  void shake() {
    controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 15.0).chain(CurveTween(curve: Curves.elasticIn)).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        }
      });

    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyLarge!.color, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.3),
      backgroundColor: Theme.of(context).cardColor,
      title: Text(widget.title!, style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color)),
      centerTitle: true,
      actions: [AnimatedBuilder(
        animation: offsetAnimation,
        builder: (buildContext, child) {
          return Container(
            padding: EdgeInsets.only(left: offsetAnimation.value + 15.0, right: 15.0 - offsetAnimation.value),
            child: IconButton(
              icon: Stack(clipBehavior: Clip.none, children: [
                Icon(Icons.shopping_cart, color: Theme.of(context).disabledColor.withOpacity(0.3), size: 30),
                Positioned(
                  top: -7, right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                    child: Text('${Provider.of<CartProvider>(context).cartList.length}', style: TextStyle(color: Theme.of(context).cardColor, fontSize: 10)),
                  ),
                ),
              ]),
              onPressed: () {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => const CartScreen(
                      isBackEnable: true,
                    )));
                // Provider.of<SplashProvider>(context, listen: false).setPageIndex(2);
                // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MenuScreen()));
              },
            ),
          );
        },
      )],
    );
  }
}
