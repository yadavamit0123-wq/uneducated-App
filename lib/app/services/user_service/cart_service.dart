import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:webinar/app/models/cart_model.dart';
import 'package:webinar/app/models/checkout_model.dart';
import 'package:webinar/app/models/cart_model.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/analytics_service.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/error_handler.dart';
import 'package:webinar/locator.dart';

import '../../../common/enums/error_enum.dart';
import '../../../common/utils/constants.dart';
import '../../../common/utils/http_handler.dart';
import '../authentication_service/authentication_service.dart';

class CartService{


  static Future<CartModel?> getCart()async{
    try{
      String url = '${Constants.baseUrl}panel/cart/list';


      Response res = await httpGetWithToken(
        url,   
        isRedirectingStatusCode: false
      );
      
      var jsonResponse = parseCleanJson(res.body.toString());
      
      
      if(jsonResponse['success']){
        locator<UserProvider>().setCartData(CartModel.fromJson(jsonResponse['data']?['cart'] ?? {}));
        return CartModel.fromJson(jsonResponse['data']?['cart'] ?? {});
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return null;
      }

    }catch(e){
      return null;
    }
  }

  static Future<String?> webCheckout()async{
    try{
      String url = '${Constants.baseUrl}panel/cart/web_checkout';


      Response res = await httpPostWithToken(
        url,   
        {},
        isRedirectingStatusCode: false
      );
      
      var jsonResponse = parseCleanJson(res.body.toString());
      
      
      if(jsonResponse['success']){
        return jsonResponse['data']['link'];
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return null;
      }

    }catch(e){
      return null;
    }
  }

  static Future validateCoupon(String coupon)async{
    try{
      String url = '${Constants.baseUrl}panel/cart/coupon/validate';


      Response res = await httpPostWithToken(
        url,   
        {
          "coupon" : coupon
        },
        isRedirectingStatusCode: false
      );
      
      var jsonResponse = parseCleanJson(res.body.toString());
      
      if(jsonResponse['success']){
        
        return {
          'amount' : Amounts.fromJson(jsonResponse['data']['amounts']),
          'discount_id' : jsonResponse['data']['discount']['id']
        };
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return null;
      }

    }catch(e){
      return null;
    }
  }
    
  
  static Future<bool> store(
    int courseId,
    int ticketId, {
    String? itemName,
    double? price,
    String category = 'course',
  })async{
    try{
      String url = '${Constants.baseUrl}panel/cart/store';


      Response res = await httpPostWithToken(
        url,   
        {
          "webinar_id" : courseId.toString(),
          "ticket_id" : ticketId.toString()
        },
        isRedirectingStatusCode: false
      );
      
      var jsonResponse = parseCleanJson(res.body.toString());
      
      if(jsonResponse['success']){
        getCart();
        showSnackBar(ErrorEnum.success, appText.successAddToCartDesc);

        // Event: add_to_cart — course ticket added via CartService.store
        AnalyticsService.instance.logAddToCart(
          itemId: courseId.toString(),
          itemName: itemName ?? courseId.toString(),
          category: category,
          price: price ?? 0,
        );

        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return false;
      }

    }catch(e){
      return false;
    }
  }
  
  
  static Future<dynamic> payRequest(int gatewayId,int orderId)async{
    try{
      String url = '${Constants.baseUrl}panel/payments/request';
      


      Response res = await httpPostWithToken(
        url,   
        {
          "gateway_id" : gatewayId.toString(),
          "order_id" : orderId.toString()
        },
        isRedirectingStatusCode: false
      );
      
      var jsonResponse;
      try{
        jsonResponse = jsonDecode(res.body.toString());
      }catch(e){
        debugPrint('error cart service -------------> $e');
      }

      // print(res.statusCode);

      if(jsonResponse?['success'] ?? true){
        return res.body;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }

    }catch(e){
      return null;
    }
  }
  
  static Future<bool> credit(int orderId)async{
    try{
      String url = '${Constants.baseUrl}panel/payments/credit';


      Response res = await httpPostWithToken(
        url,   
        {
          "order_id" : orderId.toString(),
        },
        isRedirectingStatusCode: false
      );
      
      var jsonResponse = parseCleanJson(res.body.toString());
      
      if(jsonResponse['success']){
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return false;
      }

    }catch(e){
      return false;
    }
  }
    
  
  static Future<bool> subscribeApplay(int courseId)async{
    try{
      String url = '${Constants.baseUrl}panel/subscribe/apply';


      Response res = await httpPostWithToken(
        url,   
        {
          "webinar_id" : courseId.toString(),
        },
        isRedirectingStatusCode: false
      );
      
      var jsonResponse = parseCleanJson(res.body.toString());
      
      if(jsonResponse['success']){
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return false;
      }

    }catch(e){
      return false;
    }
  }
    
  
  static Future<bool> add(String itemId, String itemName, String? specifications)async{
    try{
      String url = '${Constants.baseUrl}panel/cart';

      Response res = await httpPostWithToken(
        url,   
        {
          "item_id" : itemId,
          "item_name" : itemName,
          "specifications" : specifications,
          "quantity" : "1"
        },
        isRedirectingStatusCode: false
      );
      
      var jsonResponse = parseCleanJson(res.body.toString());
      
      if(jsonResponse['success']){
        await getCart();
        showSnackBar(ErrorEnum.success, appText.successAddToCartDesc);

        final cart = locator<UserProvider>().cartData;
        Items? matchedItem;
        if (cart?.items != null) {
          for (final item in cart!.items!) {
            if (item.id?.toString() == itemId || item.title == itemName) {
              matchedItem = item;
              break;
            }
          }
        }

        // Event: add_to_cart — course/product added via CartService.add
        AnalyticsService.instance.logAddToCart(
          itemId: itemId,
          itemName: itemName,
          category: specifications?.isNotEmpty == true ? specifications! : 'course',
          price: (matchedItem?.price ?? 0).toDouble(),
        );

        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return false;
      }

    }catch(e){
      return false;
    }
  }
    

  static Future<bool> deleteCourse(int id)async{
    try{
      String url = '${Constants.baseUrl}panel/cart/$id';


      Response res = await httpDeleteWithToken(
        url,   
        {},
        isRedirectingStatusCode: false
      );
      
      var jsonResponse = parseCleanJson(res.body.toString());
      
      if(jsonResponse['success']){
        
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return false;
      }

    }catch(e){
      return false;
    }
  }
    

  static Future<CheckoutModel?> checkout()async{
    try{
      String url = '${Constants.baseUrl}panel/cart/checkout';


      Response res = await httpPostWithToken(
        url,   
        {},
        isRedirectingStatusCode: false
      );
      
      var jsonResponse = parseCleanJson(res.body.toString());
      
      if(jsonResponse['success']){
        
        return CheckoutModel.fromJson(jsonResponse['data']);
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return null;
      }

    }catch(e){
      return null;
    }
  }
    
}