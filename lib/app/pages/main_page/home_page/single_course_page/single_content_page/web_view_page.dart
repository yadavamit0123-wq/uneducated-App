
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../../common/data/app_language.dart';
import '../../../../../../common/utils/constants.dart';
import '../../../../../../locator.dart';

class WebViewPage extends StatefulWidget {
  static const String pageName = '/web-view';
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
 
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(

    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    
    cacheEnabled: true,
    javaScriptEnabled: true,
    
    useHybridComposition: false,
    sharedCookiesEnabled: true,
    
    useShouldOverrideUrlLoading: true,
    useOnLoadResource: false,


  );

  CookieManager cookieManager = CookieManager.instance();

  String? url;
  String? title;

  late WebViewController controller;
  bool isShow=false;

  bool isSendTokenInHeader=true;
  LoadRequestMethod method = LoadRequestMethod.post;

  PlatformWebViewControllerCreationParams params = const PlatformWebViewControllerCreationParams();
  String token = '';
  String csrfToken = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    


    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      url = (ModalRoute.of(context)!.settings.arguments as List)[0];
      title = (ModalRoute.of(context)!.settings.arguments as List)[1] ?? '';

      try{
        isSendTokenInHeader = (ModalRoute.of(context)!.settings.arguments as List)[2] ?? true;
      }catch(_){}
      
      try{
        method = (ModalRoute.of(context)!.settings.arguments as List)[3] ?? LoadRequestMethod.post;
      }catch(_){}

      token = await AppData.getAccessToken();
    

      isShow = true;
      setState(() {});
      
      await [
        Permission.camera,
        Permission.microphone,
      ].request();

      setState(() {});


    });
  }



  load() async {

    if(isSendTokenInHeader){
      if(csrfToken.isEmpty){
        csrfToken = await UserService.csrfToken();        
      }
    }

    var header = {
      if(isSendTokenInHeader)...{
        "Authorization": "Bearer $token",
        'X-CSRF-TOKEN': csrfToken, 
      },
      "Content-Type" : "application/json", 
      'Accept' : 'application/json',
      'x-api-key' : Constants.apiKey,
      'x-locale' : locator<AppLanguage>().currentLanguage.toLowerCase(),
      'User-Agent': "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    };

    if( !(url?.startsWith('http') ?? false) ){

      await webViewController?.loadData(
        data: url ?? '', 
        baseUrl: null, 
        historyUrl: null, 
      );

    }else{
      await webViewController?.loadUrl(
        urlRequest: URLRequest(
          method: method == LoadRequestMethod.post ? "POST" : "GET",
          url: WebUri(url ?? ''),
          headers: header,
        ),
      );

    }
  }



  @override
  Widget build(BuildContext context) {
  
    return directionality(
      child: OrientationBuilder(
        builder: (context, orientation) {
          return Scaffold(
            appBar: appbar(title: title ?? ''),
          
            body: isShow
          ? InAppWebView(
          
              onJsBeforeUnload: (nAppWebViewController, jsBeforeUnloadRequest)async{
                return JsBeforeUnloadResponse();
              },
          
              key: webViewKey,
              initialSettings: settings,
          
              onReceivedHttpError: (inAppWebViewController, webResourceRequest, webResourceResponse ){},
          
              onWebViewCreated: (controller) async {
                webViewController = controller;
                
                load();
              },
          
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT
                );
              },
              
              onLoadResource: (inAppWebViewController, loadedResource){},
              
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                
                if(isSendTokenInHeader){
                  if(!(navigationAction.request.headers?.containsKey('Authorization') ?? false)){
                    if(navigationAction.request.headers != null){
                      
                      navigationAction.request.headers?.addAll({"Authorization": "Bearer $token",});
                      controller.loadUrl(urlRequest: navigationAction.request);
                      return NavigationActionPolicy.ALLOW;
                    }
                  }
                }
          
          
                var header = {
                  if(isSendTokenInHeader)...{
                    "Authorization": "Bearer $token",
                    'X-CSRF-TOKEN': csrfToken, 
                  },
                  "Content-Type" : "application/json", 
                  'Accept' : 'application/json',
                  'x-api-key' : Constants.apiKey,
                  'x-locale' : locator<AppLanguage>().currentLanguage.toLowerCase(),
                  'User-Agent': "Mozilla/5.0 (Linux; Android 12; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Mobile Safari/537.36",
                };
          
                if(navigationAction.request.headers == null || (navigationAction.request.headers?.isEmpty ?? true)){
          
                  navigationAction.request.headers = header;
                  controller.loadUrl(urlRequest: navigationAction.request);
          
                  return NavigationActionPolicy.ALLOW;
                }
          
          
                return NavigationActionPolicy.ALLOW;
                
              },
              onLoadStop: (controller, url) async {},
              onLoadStart: (controller, url_) {

                if(url_?.uriValue != null){
                  if(url_?.uriValue.toString().startsWith(Constants.scheme) ?? false){
                    backRoute(arguments: true);
                  }
                }


              },
              onReceivedError: (controller, request, error) {},
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  setState(() {});
                }
              },
          
              onUpdateVisitedHistory: (controller, uri, isReload) {},
          
              onConsoleMessage: (controller, consoleMessage) {},
              
              onNavigationResponse: (cntr, n)async{
                return NavigationResponseAction.ALLOW;
              },
              
            )
            : loading(),
          );
        }
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    webViewController?.dispose();
    super.dispose();
  }
}