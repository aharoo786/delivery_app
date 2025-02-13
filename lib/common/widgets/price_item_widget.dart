import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_directionality_widget.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';

class PriceItemWidget extends StatelessWidget {
  const PriceItemWidget(
      {super.key,
      required this.title,
      required this.subTitle,
      this.style,
      this.isGreenColor = false,
      this.showIcon = false,
      this.isBold = false});

  final String title;
  final String subTitle;
  final TextStyle? style;
  final bool isGreenColor;
  final bool showIcon;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
        children: [
          Text(
            title,
            style: style ??
                poppinsSemiBold.copyWith(
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
          ),
          SizedBox(
            width: 4,
          ),
          showIcon
              ? Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                )
              : SizedBox(),
        ],
      ),
      CustomDirectionalityWidget(
          child: Text(
        subTitle,
        style: style ??
            poppinsSemiBold.copyWith(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color:
                  isGreenColor ? Theme.of(context).primaryColor : Colors.black,
              fontSize: 14,
            ),
      )),
    ]);
  }
}
