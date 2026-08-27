import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/widgets/authentication_widget/auth_widget.dart';
import 'package:webinar/app/widgets/authentication_widget/country_code_widget/code_country.dart';
import 'package:webinar/app/widgets/authentication_widget/register_widget/register_widget.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/enums/error_enum.dart';

import '../../../common/utils/app_text.dart';
import '../../../config/assets.dart';
import '../../../config/colors.dart';
import '../../../config/styles.dart';

class ForgetPasswordPage extends StatefulWidget {
  static const String pageName = '/forget-password';
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {

  TextEditingController mailController = TextEditingController();
  FocusNode mailNode = FocusNode();
  TextEditingController passwordController = TextEditingController();
  FocusNode passwordNode = FocusNode();
  TextEditingController retypePasswordController = TextEditingController();
  FocusNode retypePasswordNode = FocusNode();

  bool isEmptyInputs = true;
  bool isSendingData = false;

  String? otherRegisterMethod;
  bool isPhoneNumber = true;

  String? resetToken;
  String? resetEmail;

  CountryCode countryCode = CountryCode(
    code: 'IN',
    dialCode: '+91',
    flagUri: '${AppAssets.flags}en.png',
    name: 'India',
  );

  @override
  void initState() {
    super.initState();

    if ((PublicData.apiConfigData?['register_method'] ?? '') == 'email') {
      isPhoneNumber = false;
      otherRegisterMethod = 'email';
    } else {
      isPhoneNumber = true;
      otherRegisterMethod = 'phone';
    }

    mailController.addListener(_updateEmptyState);
    passwordController.addListener(_updateEmptyState);
    retypePasswordController.addListener(_updateEmptyState);
  }

  void _updateEmptyState() {
    final filled = resetToken != null
        ? passwordController.text.trim().isNotEmpty &&
            retypePasswordController.text.trim().isNotEmpty
        : mailController.text.trim().isNotEmpty;

    if (filled != !isEmptyInputs) {
      setState(() {
        isEmptyInputs = !filled;
      });
    }
  }

  @override
  void dispose() {
    mailController.dispose();
    passwordController.dispose();
    retypePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return directionality(
      child: Scaffold(
        body: Stack(
          children: [

            Positioned.fill(
              child: Image.asset(
                AppAssets.introBgPng,
                width: getSize().width,
                height: getSize().height,
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.clear,
                color: isLightMode() ? null : greyFA,
              )
            ),

            Positioned.fill(
              child: Padding(
                padding: padding(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    space(getSize().height * .11),

                    Row(
                      children: [
                        Text(
                          resetToken != null ? appText.password : appText.forgetPassword,
                          style: style24Bold(),
                        ),
                        space(0, width: 4),
                        SvgPicture.asset(AppAssets.emoji2Svg)
                      ],
                    ),

                    Text(
                      resetToken != null
                          ? appText.forgetPasswordDesc
                          : appText.forgetPasswordDesc,
                      style: style14Regular().copyWith(color: greyA5),
                    ),

                    const Spacer(flex: 2),

                    space(25),

                    if (resetToken == null) ...[
                      if (PublicData.apiConfigData?['showOtherRegisterMethod'] == '1' ||
                          PublicData.apiConfigData?['showOtherRegisterMethod'] == true) ...{
                        space(15),
                        Container(
                          decoration: BoxDecoration(
                            color: whiteFF_26,
                            borderRadius: borderRadius(),
                          ),
                          width: getSize().width,
                          height: 52,
                          child: Row(
                            children: [
                              AuthWidget.accountTypeWidget(
                                  appText.email, otherRegisterMethod ?? '', 'email', () {
                                setState(() {
                                  otherRegisterMethod = 'email';
                                  isPhoneNumber = false;
                                  mailController.clear();
                                });
                              }),
                              AuthWidget.accountTypeWidget(
                                  appText.phone, otherRegisterMethod ?? '', 'phone', () {
                                setState(() {
                                  otherRegisterMethod = 'phone';
                                  isPhoneNumber = true;
                                  mailController.clear();
                                });
                              }),
                            ],
                          ),
                        ),
                        space(15),
                      },

                      if (isPhoneNumber) ...{
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                CountryCode? newData =
                                    await RegisterWidget.showCountryDialog();
                                if (newData != null) {
                                  countryCode = newData;
                                  setState(() {});
                                }
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: whiteFF_26,
                                  borderRadius: borderRadius(),
                                ),
                                alignment: Alignment.center,
                                child: ClipRRect(
                                  borderRadius: borderRadius(radius: 50),
                                  child: Image.asset(
                                    countryCode.flagUri ?? '',
                                    width: 21,
                                    height: 19,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            space(0, width: 15),
                            Expanded(
                                child: input(mailController, mailNode, appText.phoneNumber)),
                          ],
                        ),
                      } else ...{
                        input(mailController, mailNode, appText.email,
                            iconPathLeft: AppAssets.mailSvg, leftIconSize: 14),
                      },
                    ] else ...[
                      input(passwordController, passwordNode, appText.password,
                          iconPathLeft: AppAssets.passwordSvg,
                          leftIconSize: 14,
                          isPassword: true),
                      space(16),
                      input(retypePasswordController, retypePasswordNode, appText.retypePassword,
                          iconPathLeft: AppAssets.passwordSvg,
                          leftIconSize: 14,
                          isPassword: true),
                    ],

                    space(16),

                    Center(
                      child: button(
                        onTap: () async {
                          if (isEmptyInputs) return;

                          setState(() {
                            isSendingData = true;
                          });

                          if (resetToken != null) {
                            if (passwordController.text.trim() !=
                                retypePasswordController.text.trim()) {
                              showSnackBar(ErrorEnum.alert, appText.passwordAndRetypePassNotMatch);
                              setState(() {
                                isSendingData = false;
                              });
                              return;
                            }

                            final success = await AuthenticationService.resetPasswordEmail(
                              token: resetToken!,
                              email: resetEmail!,
                              password: passwordController.text.trim(),
                              passwordConfirmation: retypePasswordController.text.trim(),
                            );

                            if (success) {
                              nextRoute(LoginPage.pageName, isClearBackRoutes: true);
                            }
                          } else {
                            final res = await AuthenticationService.forgetPassword(
                              isPhoneNumber ? countryCode.dialCode : null,
                              mailController.text.trim(),
                            );

                            if (res != null) {
                              if (isPhoneNumber) {
                                // SMS 6 digits = new password — no OTP screen
                                nextRoute(LoginPage.pageName, isClearBackRoutes: true);
                              } else if (res['token'] != null) {
                                setState(() {
                                  resetToken = res['token'].toString();
                                  resetEmail = mailController.text.trim();
                                  isEmptyInputs = true;
                                });
                              }
                            }
                          }

                          setState(() {
                            isSendingData = false;
                          });
                        },
                        width: getSize().width,
                        height: 52,
                        text: resetToken != null ? appText.submit : appText.verifyMyAccount,
                        bgColor: isEmptyInputs ? greyCF : green77(),
                        textColor: Colors.white,
                        borderColor: Colors.transparent,
                        isLoading: isSendingData,
                      ),
                    ),

                    const Spacer(flex: 3),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          appText.haveAnAccount,
                          style: style16Regular(),
                        ),
                        space(0, width: 2),
                        GestureDetector(
                          onTap: () {
                            nextRoute(LoginPage.pageName, isClearBackRoutes: true);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            appText.login,
                            style: style16Regular(),
                          ),
                        )
                      ],
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}
