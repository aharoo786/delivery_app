import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/onboarding/domain/models/onboarding_model.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';

class OnBoardingWidget extends StatelessWidget {
  final OnBoardingModel onBoardingModel;
  const OnBoardingWidget({super.key, required this.onBoardingModel});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeExtraLarge),
          child: Image.asset(onBoardingModel.imageUrl),
        ),
      ),
      SizedBox(
        height: 60,
      ),
      Text(
        onBoardingModel.title,
        style: poppinsBold.copyWith(
          fontSize: Dimensions.fontSizeOverLarge,
          color: Theme.of(context).textTheme.titleMedium?.color,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(
        height: 12,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          onBoardingModel.description,
          style: poppinsLight.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              fontWeight: FontWeight.w500,
              color: Color(0xff828385)),
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(
        height: 50,
      ),
    ]);
  }
}
