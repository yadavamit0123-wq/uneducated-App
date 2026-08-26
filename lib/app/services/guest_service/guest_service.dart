
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:webinar/app/models/currency_model.dart';
import 'package:webinar/app/models/register_config_model.dart';
import 'package:webinar/common/data/api_public_data.dart';

import '../../../common/utils/constants.dart';
import '../../../common/utils/http_handler.dart';
import '../authentication_service/authentication_service.dart';

class GuestService{

  static Future<List<CurrencyModel>> getCurrencyList()async{
    List<CurrencyModel> data = [];
    try{

      String url = '${Constants.baseUrl}currency/list';


      Response res = await httpGet(url);
        
      var jsonRes = parseCleanJson(res.body.toString());

      if (jsonRes['success']) {
        jsonRes['data'].forEach((json){
          data.add(CurrencyModel.fromJson(json));
        });


        PublicData.currencyListData = data;
        return data;
      }else{
        return data;
      }


    }catch(e){
      return data;
    }
  }

  static Future<List<String>> getTimeZone()async{
    List<String> data = [];
    try{

      String url = '${Constants.baseUrl}timezones';


      Response res = await httpGet(url);
        
      var jsonRes = parseCleanJson(res.body.toString());

      if (jsonRes['success']) {


        return List.from(jsonRes['data']);
      }else{
        return data;
      }


    }catch(e){
      return data;
    }
  }

  static Future config()async{
    try{
      String url = '${Constants.baseUrl}config';

      Response res = await httpGet(
        url, 
      );

      var jsonResponse = parseCleanJson(res.body.toString());

      if(res.statusCode == 200){
        
        PublicData.apiConfigData = jsonResponse['data'];
        return jsonResponse['data'];
      }else{

        return null;
      }

    }catch(e){
      return null;
    }
  }

  static Future<RegisterConfigModel?> registerConfig(String role)async{
    try{
      String url = '${Constants.baseUrl}config/register/$role';

      Response res = await httpGet(
        url, 
      );
      debugPrint('reasonPhase ========> ${res.reasonPhrase}');
      debugPrint('res ========> ${res.body}');

      var jsonResponse = parseCleanJson(res.body.toString());

      if(res.statusCode == 200){
        return RegisterConfigModel.fromJson(jsonResponse['data']);
      }else{

        return null;
      }

    }catch(e){
      return null;
    }
  }

}