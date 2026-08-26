import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webinar/app/models/register_config_model.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/pages/authentication_page/verify_code_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/web_view_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/services/analytics_service.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/services/guest_service/guest_service.dart';
import 'package:webinar/app/widgets/authentication_widget/auth_widget.dart';
import 'package:webinar/app/widgets/authentication_widget/country_code_widget/code_country.dart';
import 'package:webinar/app/widgets/authentication_widget/register_widget/register_widget.dart';
import 'package:webinar/app/widgets/main_widget/main_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/config/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../common/enums/page_name_enum.dart';
import '../../../config/assets.dart';
import '../../../config/colors.dart';
import '../../../common/components.dart';
import '../../../locator.dart';
import '../../providers/page_provider.dart';

class RegisterPage extends StatefulWidget {
  static const String pageName = '/register';
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  TextEditingController mailController = TextEditingController();
  FocusNode mailNode = FocusNode();
  TextEditingController phoneController = TextEditingController();
  FocusNode phoneNode = FocusNode();
  
  TextEditingController passwordController = TextEditingController();
  FocusNode passwordNode = FocusNode();
  TextEditingController retypePasswordController = TextEditingController();
  FocusNode retypePasswordNode = FocusNode();

  bool isEmptyInputs=true;
  bool isPhoneNumber=true;
  bool isSendingData=false;


  CountryCode countryCode = CountryCode(
    code: "US",
    dialCode: "+1",
    flagUri: "${AppAssets.flags}en.png",
    name: "United States"
  );

  // user
  // teacher
  // organization
  String accountType = 'user';
  bool isLoadingAccountType = false;

  String? otherRegisterMethod;
  RegisterConfigModel? registerConfig;

  List<dynamic> selectRolesDuringRegistration = [];

  @override
  void initState() {
    
    super.initState();

    if(PublicData.apiConfigData.toString().contains('selectRolesDuringRegistration') && PublicData.apiConfigData['selectRolesDuringRegistration'] != null){
      selectRolesDuringRegistration = ((PublicData.apiConfigData['selectRolesDuringRegistration']) as List<dynamic>).toList();
    }

    if((PublicData.apiConfigData?['register_method'] ?? '') == 'email'){
      isPhoneNumber = false;
      otherRegisterMethod = 'email';
    }else{
      isPhoneNumber = true;
      otherRegisterMethod = 'phone';
    }

    mailController.addListener(() {
      if( (mailController.text.trim().isNotEmpty || phoneController.text.trim().isNotEmpty) && passwordController.text.trim().isNotEmpty && retypePasswordController.text.trim().isNotEmpty){
        if(isEmptyInputs){
          isEmptyInputs = false;
          setState(() {});
        }
      }else{
        if(!isEmptyInputs){
          isEmptyInputs = true;
          setState(() {});
        }
      }
    });

    phoneController.addListener(() {
      if( (mailController.text.trim().isNotEmpty || phoneController.text.trim().isNotEmpty) && passwordController.text.trim().isNotEmpty && retypePasswordController.text.trim().isNotEmpty){
        if(isEmptyInputs){
          isEmptyInputs = false;
          setState(() {});
        }
      }else{
        if(!isEmptyInputs){
          isEmptyInputs = true;
          setState(() {});
        }
      }
    });

    passwordController.addListener(() {
      if( (mailController.text.trim().isNotEmpty || phoneController.text.trim().isNotEmpty) && passwordController.text.trim().isNotEmpty && retypePasswordController.text.trim().isNotEmpty){
        if(isEmptyInputs){
          isEmptyInputs = false;
          setState(() {});
        }
      }else{
        if(!isEmptyInputs){
          isEmptyInputs = true;
          setState(() {});
        }
      }
    });

    retypePasswordController.addListener(() {
      if( (mailController.text.trim().isNotEmpty || phoneController.text.trim().isNotEmpty) && passwordController.text.trim().isNotEmpty && retypePasswordController.text.trim().isNotEmpty){
        if(isEmptyInputs){
          isEmptyInputs = false;
          setState(() {});
        }
      }else{
        if(!isEmptyInputs){
          isEmptyInputs = true;
          setState(() {});
        }
      }
    });
    
    getAccountTypeFileds();

  }

  
  getAccountTypeFileds() async {
    
    setState(() {
      isLoadingAccountType = true;
    });

    registerConfig = await GuestService.registerConfig(accountType);
    debugPrint('========> ${registerConfig?.showOtherRegisterMethod}');

    setState(() {
      isLoadingAccountType = false;
    });
  }


  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      onPopInvoked: (re){
        MainWidget.showExitDialog();
      },
      child: directionality(
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: padding(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
      
                      space(getSize().height * .11),
      
                      // title
                      Row(
                        children: [
      
                          Text(
                            appText.createAccount,
                            style: style24Bold(),
                          ),
      
                          space(0,width: 4),
      
                          SvgPicture.asset(AppAssets.emoji2Svg)
                        ],
                      ),
      
                      // desc
                      Text(
                        appText.createAccountDesc,
                        style: style14Regular().copyWith(color: greyA5),
                      ),
      
                      space(50),
      
                      

                      if(selectRolesDuringRegistration.contains(PublicData.teacherRole) && selectRolesDuringRegistration.contains(PublicData.organizationRole))...{
                        
                        Text(
                          appText.accountType,
                          style: style14Regular().copyWith(color: greyB2),
                        ),
        
                        space(8),

                        // account types
                        Container(
                          decoration: BoxDecoration(
                            color: whiteFF_26,
                            borderRadius: borderRadius()
                          ),
                          
                          width: getSize().width,
                          height:  52,
        
                          child: Row(
                            children: [
                              
                              // student
                              AuthWidget.accountTypeWidget(appText.student, accountType, PublicData.userRole, (){
                                setState(() {
                                  accountType = PublicData.userRole;
                                });
                                getAccountTypeFileds();
                              }),
                            


                              // instructor
                              if(selectRolesDuringRegistration.contains(PublicData.teacherRole))...{
                                AuthWidget.accountTypeWidget(appText.instrcutor, accountType, PublicData.teacherRole, (){
                                  setState(() {
                                    accountType = PublicData.teacherRole;
                                  });
                                  getAccountTypeFileds();
                                }),
                              },

                              
                              // organization
                              if(selectRolesDuringRegistration.contains(PublicData.organizationRole))...{
                                AuthWidget.accountTypeWidget(appText.organization, accountType, PublicData.organizationRole, (){
                                  setState(() {
                                    accountType = PublicData.organizationRole;
                                  });
                                  getAccountTypeFileds();
                                }),
                              }

        
                            ],
                          ),
                        ),
                      },
                      
      
                      // Other Register Method
                      if(registerConfig?.showOtherRegisterMethod != null)...{
                        space(15),
      
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: borderRadius()
                          ),
                          
                          width: getSize().width,
                          height:  52,
      
                          child: Row(
                            children: [
      
                              // email
                              AuthWidget.accountTypeWidget(appText.email, otherRegisterMethod ?? '', 'email', (){
                                setState(() {
                                  otherRegisterMethod = 'email';
                                  isPhoneNumber = false;
                                });
                              }),
      
                              // email
                              AuthWidget.accountTypeWidget(appText.phone, otherRegisterMethod ?? '', 'phone', (){
                                setState(() {
                                  otherRegisterMethod = 'phone';
                                  isPhoneNumber = true;
                                });
                              }),
      
                            ],
                          )
                        ),
                      },
      
                      space(13),
      
                      if(isPhoneNumber)...{
                        
                        Row(
                          children: [
      
                            // country code
                            GestureDetector(
                              onTap: () async {
                                CountryCode? newData = await RegisterWidget.showCountryDialog();
      
                                if(newData != null){
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
                                  borderRadius: borderRadius()
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
      
                            space(0,width: 15),
      
                            Expanded(child: input(phoneController, phoneNode, appText.phoneNumber))  
                          ],
                        )
                      }else...{
                        input(mailController, mailNode, appText.yourEmail, iconPathLeft: AppAssets.mailSvg,leftIconSize: 14),
                      },
      
                      space(16),
                      
                      input(passwordController, passwordNode, appText.password, iconPathLeft: AppAssets.passwordSvg,leftIconSize: 14,isPassword: true),
      
                      space(16),
                      
                      input(retypePasswordController, retypePasswordNode, appText.retypePassword, iconPathLeft: AppAssets.passwordSvg,leftIconSize: 14,isPassword: true),
      
      
                      isLoadingAccountType
                    ? loading()
                    : Column(
                        children: [
                          
                          ...List.generate(registerConfig?.formFields?.fields?.length ?? 0, (index) {
                            return registerConfig?.formFields?.fields?[index].getWidget() ?? const SizedBox();
                          })
                        ],
                      ),
      
                      space(32),
      
                      Center(
                        child: button(
                          onTap: () async {
                            
                            if(!isEmptyInputs){
      
                              if(registerConfig?.formFields?.fields != null){
                                for (var i = 0; i < (registerConfig?.formFields?.fields?.length ?? 0); i++) {
                                  if(registerConfig?.formFields?.fields?[i].isRequired == 1 && registerConfig?.formFields?.fields?[i].userSelectedData == null){
      
                                    if(registerConfig?.formFields?.fields?[i].type != 'toggle'){
                                      
                                      showSnackBar(ErrorEnum.alert, '${appText.pleaseReview} ${registerConfig?.formFields?.fields?[i].getTitle()}');
                                      return;
                                    }
                                    
                                  }
                                }
                              }
      

                              if(passwordController.text.trim().compareTo(retypePasswordController.text.trim()) == 0 ){
      
                                setState(() {
                                  isSendingData = true;
                                });
                                
                                // if(registerConfig?.registerMethod == 'email'){
                                if(otherRegisterMethod == 'email'){
                                  Map? res = await AuthenticationService.registerWithEmail( // email
                                    // registerConfig?.registerMethod ?? '',
                                    otherRegisterMethod!,
                                    mailController.text.trim(), 
                                    passwordController.text.trim(), 
                                    retypePasswordController.text.trim(),
                                    accountType,
                                    registerConfig?.formFields?.fields
                                  );
      
                                  
                                  if(res != null){
                                    if(registerConfig?.disableRegistrationVerification ?? false){
                                      // Event: sign_up — registration complete without verification
                                      AnalyticsService.instance.logSignUp(
                                        method: otherRegisterMethod == 'email' ? 'email' : 'mobile',
                                      );
                                      locator<PageProvider>().setPage(PageNames.home);
                                      nextRoute(MainPage.pageName, arguments: res['user_id']);
                                    }else{

                                      if(res['step'] == 'stored' || res['step'] == 'go_step_2'){
                                        nextRoute(VerifyCodePage.pageName, arguments: {
                                          'user_id' : res['user_id'],
                                          'email': mailController.text.trim(),
                                          'password': passwordController.text.trim(),
                                          'retypePassword': retypePasswordController.text.trim(),
                                        });
        
                                      }else if(res['step'] == 'go_step_3'){
                                        // Event: sign_up — registration complete (step 3)
                                        AnalyticsService.instance.logSignUp(
                                          method: otherRegisterMethod == 'email' ? 'email' : 'mobile',
                                        );
                                        AppData.canShowFinalizeSheet = true;
                                        locator<PageProvider>().setPage(PageNames.home);
                                        nextRoute(MainPage.pageName, arguments: res['user_id']);
                                      }
                                    }

                                  }
      
                                }else{
      
                                  Map? res = await AuthenticationService.registerWithPhone( // mobile
                                    // registerConfig?.registerMethod ?? '',
                                    otherRegisterMethod!,
                                    countryCode.dialCode.toString(),
                                    phoneController.text.trim(), 
                                    passwordController.text.trim(), 
                                    retypePasswordController.text.trim(),
                                    accountType,
                                    registerConfig?.formFields?.fields
                                  );
                                  
                                  if(res != null){
                                    if(registerConfig?.disableRegistrationVerification ?? false){
                                      // Event: sign_up — registration complete without verification
                                      AnalyticsService.instance.logSignUp(
                                        method: otherRegisterMethod == 'email' ? 'email' : 'mobile',
                                      );
                                      locator<PageProvider>().setPage(PageNames.home);
                                      nextRoute(MainPage.pageName, arguments: res['user_id']);
                                    }else{
                                      if(res['step'] == 'stored' || res['step'] == 'go_step_2'){
                                      
                                        nextRoute(VerifyCodePage.pageName, arguments: {
                                          'user_id' : res['user_id'],
                                          'countryCode': countryCode.dialCode.toString(),
                                          'phone': phoneController.text.trim(),
                                          'password': passwordController.text.trim(),
                                          'retypePassword': retypePasswordController.text.trim()
                                        });
        
                                      }else if(res['step'] == 'go_step_3'){
                                        // Event: sign_up — registration complete (step 3)
                                        AnalyticsService.instance.logSignUp(
                                          method: otherRegisterMethod == 'email' ? 'email' : 'mobile',
                                        );
                                        AppData.canShowFinalizeSheet = true;
                                        locator<PageProvider>().setPage(PageNames.home);
                                        nextRoute(MainPage.pageName, arguments: res['user_id']);
                                      }
                                    }
                                  }
                                }
                        
                                setState(() {
                                  isSendingData = false;
                                });
                              }
                      
                            }
      
                          }, 
                          width: getSize().width, 
                          height: 52, 
                          text: appText.createAnAccount, 
                          bgColor: isEmptyInputs ? greyCF : green77(), 
                          textColor: Colors.white, 
                          borderColor: Colors.transparent,
                          isLoading: isSendingData
                        ),
                      ),
      
                      space(16),
      
                      // termsPoliciesDesc
                      Center(
                        child: GestureDetector(
                          onTap: (){
                            nextRoute(WebViewPage.pageName, arguments: ['${Constants.dommain}/pages/app-terms', appText.webinar, false, LoadRequestMethod.get]);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            appText.termsPoliciesDesc,
                            style: style14Regular().copyWith(color: greyA5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
      
                      space(80),
      
                      // haveAnAccount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            appText.haveAnAccount,
                            style: style16Regular(),
                          ),
      
                          space(0,width: 2),
      
                          GestureDetector(
                            onTap: (){
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
      
                      space(25),
      
      
                    ],
                  ),
                )
              )
            ],
          ),
        )
      ),
    );
  }


  


  Widget socialWidget(String icon,Function onTap){
    return GestureDetector(
      onTap: (){
        onTap();
      },
      child: Container(
        width: 98,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: whiteFF_26,
          borderRadius: borderRadius(radius: 16),
        ),

        child: SvgPicture.asset(icon,width: 30,),
      ),
    );
  }


}