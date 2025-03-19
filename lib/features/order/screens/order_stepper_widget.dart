import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrderStepper extends StatelessWidget {
  final String status;
  final int currentStep; // 0 -> Accepted, 1 -> Cooking, 2 -> Pickup, 3 -> Delivered
  const OrderStepper({super.key, required this.currentStep , required this.status});

  @override
  Widget build(BuildContext context) {
    List<String> steps = ['Placed' ,  "Accepted", "Cooking", "Pickup", "Delivered"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length, (index) {
        bool isCompleted = index < currentStep;
        bool isActive = index == currentStep;
        bool isFuture = index > currentStep;
        Color stepColor = isCompleted || isActive ? Colors.lightGreen.shade300 : Colors.grey.shade300;
        Color textColor = isFuture ? Colors.grey.shade400 : Colors.black;
        Color lineColor = isCompleted ? Colors.lightGreen.shade300 : Colors.grey.shade300;

        return Expanded(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    // const SizedBox(width: 5),
                    // Step Circle
                    Container(
                      width: 40,
                      height: 40,
                      // margin: EdgeInsets.only(right: 10, left: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: stepColor,
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.black)
                          : isActive
                              ? const CupertinoActivityIndicator(color: Colors.black)
                              : null,
                    ),
                    const SizedBox(width: 10),
                    // Right Line
                    if (index != steps.length - 1)
                      Expanded(
                        child: Container(height: 2, color: lineColor),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 5),

              // Step Text
              Text(
                steps[index],
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
