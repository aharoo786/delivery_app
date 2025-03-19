import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../common/widgets/custom_image_widget.dart';
import '../domain/models/order_model.dart';

class ProfileCard extends StatelessWidget {
  final DeliveryMan? deliveryMan;
  const ProfileCard({super.key, required this.deliveryMan});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomImageWidget(
            image: deliveryMan?.identityImage ?? '',
            height: 65,
            width: 65,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),

        // Name and Role
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delivery Guy",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${deliveryMan?.fName ?? ''} ${deliveryMan?.lName ?? ''}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),

        const Spacer(),

        // Rating
        Column(
          children: [
            if (deliveryMan?.phone != null) ...{
              InkWell(
                onTap: () => launchUrlString('tel:${deliveryMan?.phone}'),
                child: const Icon(Icons.phone_outlined),
              ),
              const SizedBox(height: 5),
            },
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  (deliveryMan?.rating != null && (deliveryMan?.rating?.isNotEmpty ?? false)) ? '${deliveryMan?.rating?[0].average ?? ''}' : '0.0',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
