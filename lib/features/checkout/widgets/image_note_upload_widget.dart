import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/widgets/custom_alert_dialog_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_shadow_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_single_child_list_widget.dart';
import 'package:flutter_grocery/features/order/providers/image_note_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class ImageNoteUploadWidget extends StatelessWidget {
  const ImageNoteUploadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfigModel? configModel = Provider.of<SplashProvider>(context, listen: false).configModel;

    return (configModel?.orderImageStatus ?? false)
        ? CustomShadowWidget(
            child: Consumer<OrderImageNoteProvider>(builder: (context, imageNoteProvider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// **Title**
                  Text(
                    "Upload Prescription",
                    style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  /// **Images Row**
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        /// **Uploaded Images**
                        ...List.generate(
                          imageNoteProvider.imageFiles?.length ?? 0,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                            child: Stack(
                              children: [
                                /// **Image Container**
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ResponsiveHelper.isWeb()
                                        ? Image.network(
                                            imageNoteProvider.imageFiles![index]!.path,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(imageNoteProvider.imageFiles![index]!.path),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),

                                /// **Delete Button (X)**
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: InkWell(
                                    onTap: () => imageNoteProvider.removeImage(index),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// **"Add Image" Box**
                        InkWell(
                          onTap: () => _onImageUpload(context),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400, width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: Colors.green, size: 30),
                                SizedBox(height: 5),
                                Text("Add Image", style: TextStyle(color: Colors.green, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          )
        : const SizedBox();
  }

  /// **Image Upload Function**
  void _onImageUpload(BuildContext context) {
    final OrderImageNoteProvider orderImageNoteProvider = Provider.of<OrderImageNoteProvider>(context, listen: false);

    if (kIsWeb) {
      orderImageNoteProvider.onPickImage(false);
    } else {
      ResponsiveHelper.showDialogOrBottomSheet(
        context,
        CustomAlertDialogWidget(
          child: Column(
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  orderImageNoteProvider.onPickImage(false, fromCamera: true);
                },
                leading: const Icon(Icons.camera_alt),
                title: Text(getTranslated('camera', context)),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  orderImageNoteProvider.onPickImage(false);
                },
                leading: const Icon(Icons.image),
                title: Text(getTranslated('media', context)),
              ),
            ],
          ),
        ),
      );
    }
  }
}
