import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/custom_image_widget.dart';
import '../../../common/widgets/custom_text_field_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/color_resources.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../../category/widgets/category_item_widget.dart';
import '../../splash/providers/splash_provider.dart';

class CouponScreen extends StatelessWidget {
  const CouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
          : AppBar(backgroundColor: Colors.white,
        scrolledUnderElevation: 0.0,
        leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back,color: Colors.black)),
      )),
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 15),
            Text(
              'Coupons',
              style: poppinsSemiBold.copyWith(
                fontWeight: FontWeight.w600,
                fontSize:ResponsiveHelper.isDesktop(context)
                    ? Dimensions.fontSizeExtraLarge
                    : 28,),
            ),
            Container(
              // color: Colors.red,
              color: Theme.of(context).disabledColor.withOpacity(0.001),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextFieldWidget(
                      fillColor: Theme.of(context).disabledColor.withOpacity(0.001),
                      hintText: 'Type coupon code',
                      showOneSideBorerRadius:true,
                      isShowBorder: false,
                      prefixAssetImageColor: Colors.black,
                      isShowPrefixIcon: false,
                      prefixAssetUrl: Images.search,
                      // controller: _searchController,
                      inputAction: TextInputAction.search,
                      isIcon: true,
                      onSubmit: (text) {

                      },
                    ),
                  ),
                  Container(
                      width: 70,
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                      // alignment: Alignment.center,
                      // margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius:   BorderRadius.only(
                             topLeft : Radius.circular(0.0),
                              bottomLeft: Radius.circular(0.0),
                              topRight: Radius.circular(ResponsiveHelper.isDesktop(context)? 20 : 12),
                              bottomRight: Radius.circular(ResponsiveHelper.isDesktop(context)? 20 : 12)

                          )
                      ),
                      child: Center(
                        child:  Text(
                          'Apply',
                          style: poppinsRegular.copyWith(
                              color:Colors.white ,
                              fontSize: Dimensions.fontSizeDefault,
                              fontWeight: FontWeight.w500
                            // color: categoryProvider.selectedCategoryIndex == -1 ? Theme.of(context).canvasColor : Colors.black ,
                          ),
                        ),
                      )
                  )


                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Available coupon',
              style: poppinsSemiBold.copyWith(
                fontWeight: FontWeight.w600,
                fontSize:ResponsiveHelper.isDesktop(context)
                    ? Dimensions.fontSizeExtraLarge
                    : 18,),
            ),
            // const SizedBox(height: 24),

            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount:12,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                itemBuilder: (context, index) {
                  // CategoryModel category = categoryProvider.categoryList![index];
                  return InkWell(
                    onTap: () {
                    },
                    child: _searchScreenCategoryWidget(context:context,isBrand: false),
                    // child: CategoryItemWidget(
                    //   title: "category.name",
                    //   icon: Images.fruit,
                    //   isSelected: false,
                    // ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

          ],
        ),
      ),
    );
  }
  _searchScreenCategoryWidget({context,isBrand}){
    return Container(
      width: 84,
      // height: 110,
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Theme.of(context).cardColor
      ),
      child: Column(
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Container(
              height: 60,
              width: 60,
              alignment: Alignment.center,
              //padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(//DEE2E6
                      color: ColorResources.borderColor,
                      width: 1)
              ),
              child: Image.asset(
                 Images.mycoupon,
                fit: BoxFit.cover, width: 100, height: 100,
              ),
            ),
            const  SizedBox(width: 10,),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // width: 100,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeExtraSmall,vertical: Dimensions.paddingSizeExtraSmall ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(2),
                  ),child:  Text(
                  'AXIOSBNK40',
                  style: poppinsSemiBold.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize:ResponsiveHelper.isDesktop(context)
                        ? Dimensions.fontSizeExtraLarge
                        : 11,),
                ),),
                SizedBox(height: 4,),

                Text("40% OFF up to 2265",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: poppinsSemiBold.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge?.color
                        )),
                SizedBox(height: 4,),

                Row(
                  children: [
                    Text(
                      'View Details',
                      style: poppinsSemiBold.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,),
                    ),
                    SizedBox(width: 4,),
                    Icon(Icons.keyboard_arrow_down_outlined,size: 11,),
                  ],
                )
              ],
            ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(top:25),
            child: Text(
                'Apply',
                style: poppinsSemiBold.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize:ResponsiveHelper.isDesktop(context)
                        ? Dimensions.fontSizeExtraLarge
                        : 14,
                    color: Theme.of(context).primaryColor
                )),
          ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Divider(color: ColorResources.borderColor,),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
      ),
    );
  }
}
