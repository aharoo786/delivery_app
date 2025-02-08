import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_pop_scope_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/auth/domain/models/user_log_data.dart';
import 'package:flutter_grocery/features/auth/enum/from_page_enum.dart';
import 'package:flutter_grocery/features/auth/enum/verification_type_enum.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/auth/providers/verification_provider.dart';
import 'package:flutter_grocery/features/auth/widgets/social_login_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/auth_helper.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/helper/phone_number_checker_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class SendOtpScreen extends StatefulWidget {
  const SendOtpScreen({super.key});

  @override
  State<SendOtpScreen> createState() => _SendOtpScreenState();
}

class _SendOtpScreenState extends State<SendOtpScreen> {
  String? countryCode;
  TextEditingController? _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController();

    final ConfigModel configModel =
        Provider.of<SplashProvider>(context, listen: false).configModel!;
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    UserLogData? userData = authProvider.getUserData();
    if (userData != null && userData.loginType == FromPage.otp.name) {
      if (userData.phoneNumber != null) {
        _phoneNumberController!.text = PhoneNumberCheckerHelper.getPhoneNumber(
                userData.phoneNumber ?? '', userData.countryCode ?? '') ??
            '';
      }
      countryCode ??= userData.countryCode;
    } else {
      countryCode ??=
          CountryCode.fromCountryCode(configModel.country!).dialCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ConfigModel configModel =
        Provider.of<SplashProvider>(context, listen: false).configModel!;

    print(
        "------------------------ ROUTE IS ${ModalRoute.of(context)?.settings.name}");
    print("kjjkkjkjllkjjklkljlkjklj");

    return CustomPopScopeWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
            : PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: CustomAppBarWidget(
                  isBackButtonExist: true,
                  title: '',
                  onBackPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
        body: SafeArea(
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  Images.loginImage,
                  scale: 3,
                  fit: BoxFit.scaleDown,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Get started with App",
                          style: poppinsBold.copyWith(
                            fontSize: Dimensions.fontSizeOverLarge,
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Login or signup to use the app",
                          style: poppinsLight.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff828385)),
                        ),
                        const SizedBox(height: 25),
                        CustomTextFieldWidget(
                          countryDialCode: countryCode,
                          onCountryChanged: (CountryCode value) =>
                              countryCode = value.dialCode,
                          hintText: getTranslated('number_hint', context),
                          isShowBorder: true,
                          controller: _phoneNumberController,
                          inputType: TextInputType.phone,
                          title:
                              getTranslated('Enter the phone number', context),
                        ),
                        Spacer(),
                        Consumer<VerificationProvider>(
                            builder: (context, verificationProvider, child) {
                          return CustomButtonWidget(
                            isLoading: verificationProvider.isLoading,
                            buttonText: getTranslated('Continue', context),
                            onPressed: () async {
                              if (_phoneNumberController!.text.isEmpty) {
                                showCustomSnackBarHelper(getTranslated(
                                    'enter_phone_number', context));
                              } else {
                                String phoneWithCountryCode = countryCode! +
                                    _phoneNumberController!.text.trim();
                                if (PhoneNumberCheckerHelper
                                    .isPhoneValidWithCountryCode(
                                        phoneWithCountryCode)) {
                                  if (AuthHelper.isPhoneVerificationEnable(
                                      configModel)) {
                                    print(
                                        "-----------(SEND)-----Phone Number With Country Code $phoneWithCountryCode");
                                    print(
                                        "-----------(SEND)-----VerificationType ${VerificationType.phone.name}");
                                    print(
                                        "-----------(SEND)-----FromPage ${FromPage.otp.name}");
                                    await verificationProvider
                                        .sendVerificationCode(context,
                                            configModel, phoneWithCountryCode,
                                            type: VerificationType.phone.name,
                                            fromPage: FromPage.otp.name);
                                  }
                                } else {
                                  showCustomSnackBarHelper(getTranslated(
                                      'invalid_phone_number', context));
                                }
                              }
                            },
                          );
                        }),
                        RichText(
                          text: TextSpan(
                            style: poppinsMedium.copyWith(
                                fontSize: 14,
                                color: Colors.black), // Default text style
                            children: [
                              TextSpan(
                                text: "By clicking, I accept the ",
                                style: poppinsMedium.copyWith(
                                    fontSize: 13,
                                    color: Colors.black.withOpacity(0.4)),
                              ),
                              TextSpan(
                                text: "Terms & Conditions",
                                style: poppinsMedium.copyWith(
                                    fontSize: 13,
                                    color: Colors.black),
                              ),
                              TextSpan(text: " & ",style:poppinsMedium.copyWith(
                                  fontSize: 13,
                                  color: Colors.black.withOpacity(0.4)),),
                              TextSpan(
                                text: "Privacy Policy",
                                style: poppinsMedium.copyWith(
                                    fontSize: 13,
                                    color: Colors.black),
                              ),
                              TextSpan(text: "."),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
