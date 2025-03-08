import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/no_data_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/order/domain/models/order_model.dart';
import 'package:flutter_grocery/features/order/domain/models/timeslote_model.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/order/widgets/order_amount_widget.dart';
import 'package:flutter_grocery/features/order/widgets/order_details_button_view.dart';
import 'package:flutter_grocery/features/order/widgets/order_info_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/order_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/custom_button_widget.dart';
import '../../../helper/date_converter_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/color_resources.dart';
import '../../../utill/styles.dart';
import '../widgets/ordered_product_list_widget.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  final String? phoneNumber;

  const OrderDetailsScreen({super.key, required this.orderModel, required this.orderId, this.phoneNumber});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  void _loadData(BuildContext context) async {
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    orderProvider.trackOrder(widget.orderId.toString(), null, context, false, phoneNumber: widget.phoneNumber, isUpdate: false);

    if (widget.orderModel == null) {
      await splashProvider.initConfig();
    }
    await orderProvider.initializeTimeSlot();
    orderProvider.getOrderDetails(orderID: widget.orderId.toString(), phoneNumber: widget.phoneNumber);
  }

  @override
  void initState() {
    super.initState();
    _loadData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
          : CustomAppBarWidget(
              title: 'order_details'.tr,
            )) as PreferredSizeWidget?,
      body: Consumer<OrderProvider>(builder: (context, orderProvider, _) {
        print("---------------TRACK MODEL------------${orderProvider.trackModel?.toJson().toString()}");

        double deliveryCharge = OrderHelper.getDeliveryCharge(orderModel: orderProvider.trackModel);
        double itemsPrice = OrderHelper.getOrderDetailsValue(orderDetailsList: orderProvider.orderDetails, type: OrderValue.itemPrice);
        double discount = OrderHelper.getOrderDetailsValue(orderDetailsList: orderProvider.orderDetails, type: OrderValue.discount);
        double extraDiscount = OrderHelper.getExtraDiscount(trackOrder: orderProvider.trackModel);
        double tax = OrderHelper.getOrderDetailsValue(orderDetailsList: orderProvider.orderDetails, type: OrderValue.tax);
        bool isVatInclude = OrderHelper.isVatTaxInclude(orderDetailsList: orderProvider.orderDetails);
        TimeSlotModel? timeSlot = OrderHelper.getTimeSlot(timeSlotList: orderProvider.allTimeSlots, timeSlotId: orderProvider.trackModel?.timeSlotId);

        double subTotal = OrderHelper.getSubTotalAmount(itemsPrice: itemsPrice, tax: tax, isVatInclude: isVatInclude);

        double total = OrderHelper.getTotalOrderAmount(
          subTotal: subTotal,
          discount: discount,
          extraDiscount: extraDiscount,
          deliveryCharge: deliveryCharge,
          couponDiscount: orderProvider.trackModel?.couponDiscountAmount,
        );
        int itemsQuantity = OrderHelper.getOrderItemQuantity(orderProvider.orderDetails);

        return (orderProvider.orderDetails == null || orderProvider.trackModel == null)
            ? Center(child: CustomLoaderWidget(color: Theme.of(context).primaryColor))
            : orderProvider.orderDetails!.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.fontSizeLarge),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _statusWidget(
                                  title: "Order ID",
                                  subtitle: '#${orderProvider.trackModel?.id}',
                                  status: getTranslated(orderProvider.trackModel!.orderStatus, context),
                                  orderProvider: orderProvider,
                                  context: context),
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                              _statusWidget(
                                  title: "Date & Time",
                                  subtitle:
                                      '${DateConverterHelper.isoStringToLocalDateOnly(orderProvider.trackModel!.deliveryDate!)} ${DateConverterHelper.convertTimeRange(timeSlot!.startTime!, timeSlot!.endTime!, context)}',
                                  status: "",
                                  orderProvider: orderProvider,
                                  context: context),
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                              _statusWidget(
                                  title: "Delivered to",
                                  subtitle: '${orderProvider.trackModel?.deliveryAddress?.address} ',
                                  status: "",
                                  orderProvider: orderProvider,
                                  context: context),
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                              _statusWidget(
                                  title: "Payment Method",
                                  subtitle: getPaymentMethodText(orderProvider, context) + getAdditionalPaymentText(orderProvider, context),
                                  status: "",
                                  orderProvider: orderProvider,
                                  context: context),
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                              const Divider(color: ColorResources.borderColor),
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                              Text(
                                getTranslated(itemsQuantity > 1 ? 'items' : 'item', context),
                                style: poppinsSemiBold.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        const OrderedProductListWidget(),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.fontSizeLarge),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Billing Details',
                                style: poppinsSemiBold.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 16,
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                              OrderAmountWidget(
                                extraDiscount: extraDiscount,
                                itemsPrice: itemsPrice,
                                tax: tax,
                                subTotal: subTotal,
                                discount: discount,
                                couponDiscount: orderProvider.trackModel?.couponDiscountAmount ?? 0,
                                deliveryCharge: deliveryCharge,
                                total: total,
                                isVatInclude: isVatInclude,
                                paymentList: OrderHelper.getPaymentList(orderProvider.trackModel),
                                orderModel: widget.orderModel,
                                phoneNumber: widget.phoneNumber,
                                weightChargeAmount: orderProvider.trackModel?.weightChargeAmount,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                              CustomButtonWidget(
                                buttonText: 'Reorder',
                                onPressed: () {},
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : NoDataWidget(isShowButton: true, image: Images.box, title: 'order_not_found'.tr);
      }),
    );
  }

  // Column(
  // children: [
  // Expanded(child: CustomScrollView(slivers: [
  // if(ResponsiveHelper.isDesktop(context)) SliverToBoxAdapter(child: Center(
  // child: Container(
  // width: Dimensions.webScreenWidth,
  // padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
  // child: Row(
  // crossAxisAlignment: CrossAxisAlignment.start,
  // children: [
  //
  // Expanded(
  // flex: 6,
  // child: OrderInfoWidget(orderModel: widget.orderModel, timeSlot: timeSlot),
  // ),
  // const SizedBox(width: Dimensions.paddingSizeLarge),
  //
  // Expanded(
  // flex: 4,
  // child: Column(
  // mainAxisAlignment: MainAxisAlignment.start,
  // children: [
  // OrderAmountWidget(
  // extraDiscount: extraDiscount,
  // itemsPrice: itemsPrice,
  // tax: tax,
  // subTotal: subTotal,
  // discount: discount,
  // couponDiscount: orderProvider.trackModel?.couponDiscountAmount ?? 0,
  // deliveryCharge: deliveryCharge,
  // total: total,
  // isVatInclude: isVatInclude,
  // paymentList: OrderHelper.getPaymentList(orderProvider.trackModel),
  // orderModel: widget.orderModel,
  // phoneNumber: widget.phoneNumber,
  // weightChargeAmount: orderProvider.trackModel?.weightChargeAmount,
  // ),
  // const SizedBox(height: Dimensions.paddingSizeDefault),
  //
  // ]),
  // ),
  //
  // ],
  // ),
  // ),
  // )),
  //
  // if(!ResponsiveHelper.isDesktop(context)) SliverToBoxAdapter(child: Column(children: [
  // Center(child: SizedBox(
  // width: 1170,
  // child: Padding(
  // padding: const EdgeInsets.symmetric(
  // horizontal: Dimensions.paddingSizeDefault,
  // vertical: Dimensions.paddingSizeDefault,
  // ),
  // child: Column(children: [
  // OrderInfoWidget(orderModel: widget.orderModel, timeSlot: timeSlot),
  //
  // OrderAmountWidget(
  // extraDiscount: extraDiscount,
  // itemsPrice: itemsPrice,
  // tax: tax,
  // subTotal: subTotal,
  // discount: discount,
  // couponDiscount: orderProvider.trackModel?.couponDiscountAmount ?? 0,
  // deliveryCharge: deliveryCharge,
  // total: total,
  // isVatInclude: isVatInclude,
  // paymentList: OrderHelper.getPaymentList(orderProvider.trackModel),
  // weightChargeAmount: orderProvider.trackModel?.weightChargeAmount,
  // ),
  // ]),
  // ),
  // )),
  // ])),
  //
  //
  // const FooterWebWidget(footerType: FooterType.sliver),
  //
  // ])),
  //
  // if(!ResponsiveHelper.isDesktop(context)) Container(
  // padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
  // decoration: BoxDecoration(
  // color: Theme.of(context).cardColor,
  // boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5)],
  // ),
  // child: OrderDetailsButtonView(orderModel: widget.orderModel, phoneNumber: widget.phoneNumber),
  // ),
  //
  // ],
  //
  // )
  _statusWidget({context, title, subtitle, status, orderProvider}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: poppinsSemiBold.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: poppinsSemiBold.copyWith(fontWeight: FontWeight.w400, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 4),
            ],
          ),
        ),
        if (status != "")
          Row(
            children: [
              Icon(
                Icons.done,
                color: OrderStatus.pending.name == orderProvider.trackModel!.orderStatus
                    ? ColorResources.colorBlue.withOpacity(0.8)
                    : OrderStatus.out_for_delivery.name == orderProvider.trackModel!.orderStatus
                        ? ColorResources.ratingColor.withOpacity(0.8)
                        : OrderStatus.canceled.name == orderProvider.trackModel!.orderStatus
                            ? ColorResources.redColor.withOpacity(0.8)
                            : ColorResources.colorGreen.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 2),
              Text(
                status,
                style: poppinsSemiBold.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: OrderStatus.pending.name == orderProvider.trackModel!.orderStatus
                      ? ColorResources.colorBlue.withOpacity(0.8)
                      : OrderStatus.out_for_delivery.name == orderProvider.trackModel!.orderStatus
                          ? ColorResources.ratingColor.withOpacity(0.8)
                          : OrderStatus.canceled.name == orderProvider.trackModel!.orderStatus
                              ? ColorResources.redColor.withOpacity(0.8)
                              : ColorResources.colorGreen.withOpacity(0.8),
                ),
              ),
            ],
          ),
      ],
    );
  }

  _itemWidget({context, name, price}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        height: 60,
        width: 60,
        alignment: Alignment.center,
        //padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                //DEE2E6
                color: ColorResources.borderColor,
                width: 1)),
        child: Image.asset(
          Images.chicken,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        ),
      ),
      const SizedBox(
        width: 10,
      ),
      Expanded(
        child: Text(
          name,
          style: poppinsSemiBold.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraLarge : 16,
          ),
        ),
      ),
      const SizedBox(
        width: 40,
      ),
      Text(
        price,
        style: poppinsSemiBold.copyWith(
          fontWeight: FontWeight.w500,
          color: ColorResources.priceColor,
          fontSize: 16,
        ),
      ),
    ]);
  }

  _billingDetailsWidget({context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _priceRow(context: context, title: "SubTotal", values: '₹599'),
        _priceRow(context: context, title: "Promocode", values: '- ₹85', isGreenColor: true),
        _priceRow(context: context, title: "Delivery fee", values: '₹25', showIcon: true),
        _priceRow(context: context, title: "Tax & other fees ", values: '₹45', showIcon: true),
        _priceRow(context: context, title: "Total", values: '₹450', isBold: true),
      ],
    );
  }

  _priceRow({context, title, values, isGreenColor = false, showIcon = false, isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 8,
        ),
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: poppinsSemiBold.copyWith(
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            showIcon
                ? const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                  )
                : const SizedBox(),
            const Spacer(),
            Text(
              values,
              style: poppinsSemiBold.copyWith(
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                color: isGreenColor ? Theme.of(context).primaryColor : Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

  String getPaymentMethodText(OrderProvider orderProvider, BuildContext context) {
    if (orderProvider.trackModel?.paymentMethod != null && orderProvider.trackModel!.paymentMethod!.isNotEmpty) {
      if (orderProvider.trackModel!.paymentMethod == 'cash_on_delivery') {
        return getTranslated('cash_on_delivery', context);
      } else {
        return '${orderProvider.trackModel!.paymentMethod![0].toUpperCase()}'
            '${orderProvider.trackModel!.paymentMethod!.substring(1).replaceAll('_', ' ')}';
      }
    }
    return 'Digital Payment';
  }

  String getAdditionalPaymentText(OrderProvider orderProvider, BuildContext context) {
    String additionalText = '';

    if (orderProvider.trackModel?.paymentStatus == 'partially_paid') {
      additionalText += ' + ${getTranslated('wallet', context)}';
    }

    if (orderProvider.trackModel?.paymentMethod == 'offline_payment') {
      additionalText += ' + ${getTranslated('see_details', context)}';
    }

    return additionalText;
  }
}
