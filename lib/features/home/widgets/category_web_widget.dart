import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/home/widgets/category_page_widget.dart';
import 'package:flutter_grocery/features/home/widgets/category_shimmer_widget.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/category/providers/category_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/common/widgets/title_widget.dart';
import 'package:provider/provider.dart';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({super.key});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    print('------load-----------');

    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return Consumer<CategoryProvider>(builder: (context, categoryProvider, child) {
      print('--------cate-------${categoryProvider.categoryList}');
      return categoryProvider.categoryList == null
          ? const CategoriesShimmerWidget()
          : (categoryProvider.categoryList?.isNotEmpty ?? false)
              ? Column(children: [
                  ResponsiveHelper.isDesktop(context)
                      ? CategoryWebWidget(scrollController: scrollController)
                      : GridView.builder(
                          itemCount: (categoryProvider.categoryList?.length ?? 0) > 5 ? 6 : categoryProvider.categoryList?.length,
                          padding: const EdgeInsets.all(16),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: ResponsiveHelper.isMobilePhone()
                                ? 3
                                : ResponsiveHelper.isTab(context)
                                    ? 4
                                    : 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            return Center(
                              child: InkWell(
                                onTap: () {
                                  if (index == 5) {
                                    Navigator.pushNamed(context, RouteHelper.categories);
                                  } else {
                                    categoryProvider.onChangeSelectIndex(-1, notify: false);
                                    Navigator.of(context).pushNamed(
                                      RouteHelper.getCategoryProductsRoute(categoryId: '${categoryProvider.categoryList![index].id}' , subCategory: categoryProvider.categoryList?[index].name ?? ''),
                                    );
                                  }
                                },
                                child: Container(
                                    padding: const EdgeInsets.only(left: 12, top: 12, right: 7),
                                    decoration: BoxDecoration(color: const Color(0xffF2F2F3), borderRadius: BorderRadius.circular(8)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          index != 5 ? categoryProvider.categoryList![index].name! : getTranslated('view_all', context),
                                          style: poppinsBold.copyWith(fontSize: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        index != 5
                                            ? Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 15, bottom: 5),
                                                  child: CustomImageWidget(
                                                    image: '${splashProvider.baseUrls?.categoryImageUrl}/${categoryProvider.categoryList?[index].image}',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              )
                                            : Expanded(
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xffF2F2F3),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text('${(categoryProvider.categoryList?.length ?? 0) - 5}+', style: poppinsRegular),
                                                ),
                                              ),
                                      ],
                                    )),
                              ),
                            );
                          },
                        ),
                ])
              : const SizedBox();
    });
  }
}
