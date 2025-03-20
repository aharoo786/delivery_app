import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_pop_scope_widget.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/onboarding/providers/onboarding_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/features/auth/screens/login_screen.dart';
import 'package:flutter_grocery/features/onboarding/widgets/on_boarding_widget.dart';
import 'package:provider/provider.dart';

class OnBoardingScreen extends StatelessWidget {
  final PageController _pageController = PageController();

  OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<OnBoardingProvider>(context, listen: false).getBoardingList(context);

    return CustomPopScopeWidget(child: Scaffold(
      body: SafeArea(child: Consumer<OnBoardingProvider>(
        builder: (context, onBoarding, child) {
          return onBoarding.onBoardingList.isNotEmpty
              ? Column(children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _pageIndicators(onBoarding.onBoardingList, context),
                    ),
                  ),
                  Expanded(
                      child: PageView.builder(
                    itemCount: onBoarding.onBoardingList.length,
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                        child: OnBoardingWidget(onBoardingModel: onBoarding.onBoardingList[index]),
                      );
                    },
                    onPageChanged: (index) => onBoarding.setSelectIndex(index),
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.fontSizeLarge),
                    child: CustomButtonWidget(
                        buttonText: "Next",
                        icon: Icons.arrow_forward_outlined,
                        isFrontIcon: false,
                        onPressed: () {
                          if (onBoarding.selectedIndex == onBoarding.onBoardingList.length - 1) {
                            Provider.of<SplashProvider>(context, listen: false).disableIntro();
                            Navigator.of(context).pushReplacementNamed(RouteHelper.login, arguments: const LoginScreen());
                          } else {
                            _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                          }
                        }),
                  ),
                  TextButton(
                    onPressed: () {
                      Provider.of<SplashProvider>(context, listen: false).disableIntro();
                      Navigator.of(context).pushReplacementNamed(RouteHelper.login, arguments: const LoginScreen());
                    },
                    child: Text(
                      onBoarding.selectedIndex != onBoarding.onBoardingList.length - 1 ? getTranslated('skip', context) : '',
                      style: poppinsSemiBold.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  ),
                  SizedBox(
                    height: 90,
                  )
                ])
              : const SizedBox();
        },
      )),
    ));
  }

  List<Widget> _pageIndicators(var onBoardingList, BuildContext context) {
    List<Container> indicators = [];

    for (int i = 0; i < onBoardingList.length; i++) {
      indicators.add(
        Container(
          width: 90,
          height: 3,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: i == Provider.of<OnBoardingProvider>(context).selectedIndex ? Colors.black : ColorResources.getGreyColor(context),
            borderRadius: i == Provider.of<OnBoardingProvider>(context).selectedIndex ? BorderRadius.circular(50) : BorderRadius.circular(25),
          ),
        ),
      );
    }
    return indicators;
  }
}
