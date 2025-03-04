import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/enums/app_mode_enum.dart';
import 'package:flutter_grocery/features/auth/domain/models/user_log_data.dart';
import 'package:flutter_grocery/features/auth/enum/from_page_enum.dart';
import 'package:flutter_grocery/features/auth/enum/verification_type_enum.dart';
import 'package:flutter_grocery/features/auth/providers/verification_provider.dart';
import 'package:flutter_grocery/helper/auth_helper.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/helper/email_checker_helper.dart';
import 'package:flutter_grocery/helper/phone_number_checker_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_directionality_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';

class VerificationScreen extends StatefulWidget {
  final String userInput;
  final String fromPage;
  final String? session;
  const VerificationScreen(
      {super.key,
      this.session,
      required this.userInput,
      required this.fromPage});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController inputPinTextController = TextEditingController();

  @override
  void initState() {
    final VerificationProvider verificationProvider =
        Provider.of<VerificationProvider>(context, listen: false);
    verificationProvider.startVerifyTimer();
    verificationProvider.updateVerificationCode('', 6, isUpdate: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final Size size = MediaQuery.of(context).size;
    final isPhone = EmailCheckerHelper.isNotValid(widget.userInput);
    final ConfigModel? config =
        Provider.of<SplashProvider>(context, listen: false).configModel;
    final bool isFirebaseOTP =
        AuthHelper.isCustomerVerificationEnable(config) &&
            AuthHelper.isFirebaseVerificationEnable(config);

    print(
        "----------------------(VERIFICATION SCREEN)------${widget.userInput} and ${widget.fromPage}");

    String userInput = widget.userInput;
    if (!userInput.contains('+') && isPhone) {
      userInput = '+${widget.userInput.replaceAll(' ', '')}';
    }

    print(
        "----------------------(VERIFICATION SCREEN)------AFTER MODIFICATION $userInput and ${widget.fromPage}");

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: (ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(
              preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
          : CustomAppBarWidget(
              title: getTranslated('', context),
            )) as PreferredSizeWidget?,
      body: SafeArea(
        child: Consumer<VerificationProvider>(
            builder: (context, verificationProvider, child) => Container(
                  width: !ResponsiveHelper.isMobile() ? 450 : width,
                  padding: !ResponsiveHelper.isMobile()
                      ? const EdgeInsets.all(Dimensions.paddingSizeDefault)
                      : null,
                  margin: !ResponsiveHelper.isMobile()
                      ? const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeLarge)
                      : null,
                  decoration: !ResponsiveHelper.isMobile()
                      ? BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context).shadowColor,
                                blurRadius: 5,
                                spreadRadius: 1)
                          ],
                        )
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Verify your details",
                          style: poppinsBold.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            style: poppinsMedium.copyWith(
                                fontSize: 14,
                                color: Colors.black), // Default text style
                            children: [
                              TextSpan(
                                text: "Enter OTP sent to ",
                                style: poppinsMedium.copyWith(
                                    fontSize: 14,
                                    color: Colors.black.withOpacity(0.4)),
                              ),
                              TextSpan(
                                text: widget.userInput,
                                style: poppinsMedium.copyWith(
                                    fontSize: 14, color: Colors.black),
                              ),
                              TextSpan(
                                text: " via sms",
                                style: poppinsMedium.copyWith(
                                    fontSize: 14,
                                    color: Colors.black.withOpacity(0.4)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Enter OTP",
                          style: poppinsMedium.copyWith(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        PinCodeTextField(
                          controller: inputPinTextController,
                          length: 6,
                          appContext: context,
                          obscureText: false,
                          enabled: true,
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            fieldHeight: 50,
                            fieldWidth: 50,
                            borderWidth: 1,
                            borderRadius: BorderRadius.circular(4),
                            selectedColor: Colors.black,
                            selectedFillColor: const Color(0xffF2F7FB),
                            inactiveFillColor: const Color(0xffF2F7FB),
                            inactiveColor: Color(0xffDEE2E6),
                            activeColor: Colors.black,
                            activeFillColor: const Color(0xffF2F7FB),
                          ),
                          animationDuration: const Duration(milliseconds: 300),
                          backgroundColor: Colors.transparent,
                          enableActiveFill: true,
                          onChanged: (query) => verificationProvider
                              .updateVerificationCode(query, 6),
                          beforeTextPaste: (text) {
                            return true;
                          },
                        ),
                        Expanded(
                          child: Consumer<AuthProvider>(
                              builder: (context, authProvider, _) {
                            print(
                                'verification------status-----> ${verificationProvider.resendLoadingStatus}');
                            int? days, hours, minutes, seconds;

                            Duration duration = Duration(
                                seconds: verificationProvider.currentTime ?? 0);
                            days = duration.inDays;
                            hours = duration.inHours - days * 24;
                            minutes = duration.inMinutes -
                                (24 * days * 60) -
                                (hours * 60);
                            seconds = duration.inSeconds -
                                (24 * days * 60 * 60) -
                                (hours * 60 * 60) -
                                (minutes * 60);

                            return Column(children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          getTranslated(
                                              'Didn’t receive OTP?  ', context),
                                          style: poppinsRegular.copyWith(
                                              fontSize: 12)),
                                      GestureDetector(
                                        onTap: verificationProvider
                                                    .currentTime! >
                                                0
                                            ? null
                                            : () async {
                                                if (widget.fromPage !=
                                                    FromPage.forget.name) {
                                                  await verificationProvider
                                                      .sendVerificationCode(
                                                          context,
                                                          config!,
                                                          userInput,
                                                          type: isPhone
                                                              ? VerificationType
                                                                  .phone.name
                                                              : VerificationType
                                                                  .email.name,
                                                          fromPage:
                                                              widget.fromPage);
                                                } else {
                                                  bool isNumber =
                                                      EmailCheckerHelper
                                                          .isNotValid(
                                                              userInput);
                                                  if (isNumber &&
                                                      isFirebaseOTP) {
                                                    verificationProvider
                                                        .firebaseVerifyPhoneNumber(
                                                            context,
                                                            userInput,
                                                            widget.fromPage,
                                                            isForgetPassword:
                                                                true);
                                                  } else {
                                                    await authProvider
                                                        .forgetPassword(
                                                      userInput,
                                                      isNumber
                                                          ? VerificationType
                                                              .phone.name
                                                          : VerificationType
                                                              .email.name,
                                                    )
                                                        .then((value) {
                                                      verificationProvider
                                                          .startVerifyTimer();
                                                      if (value.isSuccess) {
                                                        showCustomSnackBarHelper(
                                                            getTranslated(
                                                                'resend_code_successful',
                                                                Get.context!),
                                                            isError: false);
                                                      } else {
                                                        showCustomSnackBarHelper(
                                                            value.message!);
                                                      }
                                                    });
                                                  }
                                                }

                                                // if (widget.fromSignUp) {
                                                //   await verificationProvider.sendVerificationCode(config, SignUpModel(phone: widget.emailAddress, email: widget.emailAddress));
                                                //   verificationProvider.startVerifyTimer();
                                                //
                                                // } else {
                                                //   if(isFirebaseOTP) {
                                                //     verificationProvider.firebaseVerifyPhoneNumber('${widget.emailAddress?.trim()}', isForgetPassword: true);
                                                //
                                                //   }else{
                                                //     await authProvider.forgetPassword(widget.emailAddress).then((value) {
                                                //       verificationProvider.startVerifyTimer();
                                                //
                                                //       if (value.isSuccess) {
                                                //         showCustomSnackBarHelper('resend_code_successful', isError: false);
                                                //       } else {
                                                //         showCustomSnackBarHelper(value.message!);
                                                //       }
                                                //     });
                                                //   }
                                                // }
                                              },
                                        child: Text(
                                          getTranslated('resend', context),
                                          textAlign: TextAlign.end,
                                          style: poppinsMedium.copyWith(
                                            color: Color(0xff70B943),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(width:5),

                                  Text(
                                      getTranslated(
                                          '${minutes > 0 ? '${minutes}m :' : ''}${seconds}s',
                                          context),
                                      style: poppinsRegular.copyWith(
                                          fontSize: 12)),
                                ],
                              ),
                              Spacer(),
                              CustomButtonWidget(
                                  isLoading: verificationProvider.isLoading ||
                                      (isFirebaseOTP && authProvider.isLoading),
                                  buttonText: getTranslated(
                                      'Verify & continue', context),
                                  backgroundColor: (verificationProvider
                                              .isEnableVerificationCode &&
                                          !verificationProvider
                                              .resendLoadingStatus)
                                      ? ColorResources.buttonColor
                                      : Color(0xff868E96),
                                  onPressed: (verificationProvider
                                              .isEnableVerificationCode &&
                                          !verificationProvider
                                              .resendLoadingStatus)
                                      ? () {
                                          if (isPhone &&
                                              AuthHelper
                                                  .isFirebaseVerificationEnable(
                                                      config)) {
                                            authProvider.firebaseOtpLogin(
                                              phoneNumber: widget.userInput,
                                              session: '${widget.session}',
                                              otp: verificationProvider
                                                  .verificationCode,
                                            );
                                          }
                                        }
                                      : null),
                              SizedBox(height: 40),
                            ]);
                          }),
                        ),
                      ],
                    ),
                  ),
                )),
      ),
    );
  }
}
