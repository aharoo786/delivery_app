import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class DeliveryOptionWidget extends StatelessWidget {
  final String value;
  final String? title;

  const DeliveryOptionWidget({super.key, required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, order, child) {
        bool isSelected = order.orderType == value;

        return InkWell(
          onTap: () => order.setOrderType(value),
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          child: Container(
            height: 50,
            // padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
              border: Border.all(
                color: isSelected ? Theme.of(context).dividerColor : Colors.grey.shade500,
                width: isSelected ? 1.5 : 1,
              ),
              color: isSelected ? Colors.white : Theme.of(context).cardColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio(
                  value: value,
                  groupValue: order.orderType,
                  activeColor: Theme.of(context).dividerColor,
                  onChanged: (String? value) => order.setOrderType(value),
                ),
                Text(
                  title!,
                  style: isSelected
                      ? poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall)
                      : poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

