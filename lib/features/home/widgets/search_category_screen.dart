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

class SearchCategoryScreen extends StatelessWidget {
  const SearchCategoryScreen({super.key});

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFieldWidget(
                      fillColor: Theme.of(context).disabledColor.withOpacity(0.001),
                      hintText: getTranslated('searchItem_here', context),
                      isShowBorder: false,
                      prefixAssetImageColor: Colors.black,
                      isShowPrefixIcon: true,
                      prefixAssetUrl: Images.search,
                      // controller: _searchController,
                      inputAction: TextInputAction.search,
                      isIcon: true,
                      onSubmit: (text) {
            
                      },
                    ),
                  ),
            
            
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Top Categories',
                style: poppinsSemiBold.copyWith(
                  fontSize:ResponsiveHelper.isDesktop(context)
                      ? Dimensions.fontSizeExtraLarge
                      : 20,),
              ),
              // const SizedBox(height: 24),
            
              Container(
                height: 140,
                margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                width: double.maxFinite,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount:12,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  itemBuilder: (context, index) {
                   // CategoryModel category = categoryProvider.categoryList![index];
                    return InkWell(
                      onTap: () {
                        // categoryProvider.onChangeCategoryIndex(index);
                        // categoryProvider.getSubCategoryList(context, category.id.toString());
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
              Text(
                'Popular brands',
                style: poppinsSemiBold.copyWith(
                  fontSize:ResponsiveHelper.isDesktop(context)
                      ? Dimensions.fontSizeExtraLarge
                      : 20,),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign:TextAlign.start,
              ),
              const SizedBox(height: 24),
            
              Container(
                height: 120,
                margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                width: double.maxFinite,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount:12,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  itemBuilder: (context, index) {
                    // CategoryModel category = categoryProvider.categoryList![index];
                    return InkWell(
                      onTap: () {
                        // categoryProvider.onChangeCategoryIndex(index);
                        // categoryProvider.getSubCategoryList(context, category.id.toString());
                      },
                      child: _searchScreenCategoryWidget(context:context,isBrand: true),
                      // child: CategoryItemWidget(
                      //   title: "category.name",
                      //   icon: Images.fruit,
                      //   isSelected: false,
                      // ),
                    );
                  },
                ),
              ),
              // const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Recent searches',
                    style: poppinsSemiBold.copyWith(
                      fontSize:ResponsiveHelper.isDesktop(context)
                          ? Dimensions.fontSizeExtraLarge
                          : 20,),
                  ),
                  Text(
                    'Clear all',
                    style: poppinsSemiBold.copyWith(
                      fontSize:ResponsiveHelper.isDesktop(context)
                          ? Dimensions.fontSizeExtraLarge
                          : 14,
                    color: Theme.of(context).primaryColor
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _recentSearchesWidget(context: context,text: "Milk"),
              _recentSearchesWidget(context: context,text: "Potato Chips"),
              _recentSearchesWidget(context: context,text: "Ice Cream"),
              _recentSearchesWidget(context: context,text: "Chocolates"),
            
            ],
                    ),
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
      child: Center(
        child: Column( children: [
          Container(
            height: 60,
            width: 60,
            alignment: Alignment.center,
            //padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorResources.getCategoryBgColor(context)
                // color: isSelected ? ColorResources.getCategoryBgColor(context)
                //     : ColorResources.getGreyLightColor(context).withOpacity(0.05)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
              isBrand?Images.amul:  Images.fruit,
                fit: BoxFit.cover, width: 100, height: 100,
              )
              // CustomImageWidget(
              //   image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.categoryImageUrl}/$icon',
              //   fit: BoxFit.cover, width: 100, height: 100,
              // ),
            ),
          ),
         const  SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
            child: Text(isBrand?"Amul":'Fruit &\n vegatables',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: poppinsSemiBold.copyWith(
                  fontWeight: FontWeight.w500,
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge?.color
                )),
          ),
        ]),
      ),
    );
  }
  _recentSearchesWidget({context,text}){
    return  Padding(
      padding:  EdgeInsets.symmetric(vertical:8.0),
      child: Row(
        children: [
          Icon(Icons.history, size: 16, color: Theme.of(context).hintColor.withOpacity(0.6)),
          const SizedBox(width: 13),
          Text(
            text,
          ),
          Spacer(),
          Icon(Icons.clear, size: 20),
        ],
      ),
    );
  }
}
