import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/text_hover_widget.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';

class TitleWidget extends StatelessWidget {
  final String? title;
  final Function? onTap;
  const TitleWidget({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: ResponsiveHelper.isDesktop(context) ? ColorResources.getAppBarHeaderColor(context) : Theme.of(context).canvasColor,
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.isDesktop(context) ? 0 : 16,
          vertical: 12),
      margin: ResponsiveHelper.isDesktop(context)
          ? const EdgeInsets.symmetric(horizontal: 5, vertical: 10)
          : EdgeInsets.zero,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          title!,
          style: poppinsBold.copyWith(
              fontSize: ResponsiveHelper.isDesktop(context)
                  ? Dimensions.fontSizeExtraLarge
                  : 20,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        onTap != null
            ? InkWell(
                onTap: onTap as void Function()?,
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xffF2F2F3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward)
                ),
              )
            : const SizedBox(),
      ]),
    );
  }
}
