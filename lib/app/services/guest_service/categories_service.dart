import 'dart:developer';
import 'package:http/http.dart';
import 'package:webinar/app/models/category_model.dart';
import 'package:webinar/app/models/filter_model.dart';
import '../../../common/enums/error_enum.dart';
import '../../../common/utils/constants.dart';
import '../../../common/utils/error_handler.dart';
import '../../../common/utils/http_handler.dart';
import '../authentication_service/authentication_service.dart';

class CategoriesService{


  static Future<List<CategoryModel>> trendCategories()async{
    List<CategoryModel> data = [];
    try{
      String url = '${Constants.baseUrl}trend-categories';

      Response res = await httpGet(
        url, 
      );

      log(res.body.toString());

      var jsonResponse = parseCleanJson(res.body.toString());
      if(jsonResponse['success']){
        jsonResponse['data']['categories'].forEach((json){
          data.add(CategoryModel.fromJson(json));
        });
        return data;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return data;
      }

    }catch(e){
      return data;
    }
  }

  static Future<List<CategoryModel>> categories()async{
    List<CategoryModel> data = [];
    try{
      String url = '${Constants.baseUrl}categories';

      Response res = await httpGet(
        url, 
      );

      

      var jsonResponse = parseCleanJson(res.body.toString());
      if(jsonResponse['success']){
        jsonResponse['data']['categories'].forEach((json){
          data.add(CategoryModel.fromJson(json));
        });
        return data;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return data;
      }

    }catch(e){
      return data;
    }
  }
   
  static Future<List<FilterModel>> getFilters(int id)async{
    List<FilterModel> data = [];
    try{
      String url = '${Constants.baseUrl}categories/$id/webinars';

      Response res = await httpGet(
        url, 
      );

      

      var jsonResponse = parseCleanJson(res.body.toString());
      if(jsonResponse['success']){
        jsonResponse['data']['filters'].forEach((json){
          data.add(FilterModel.fromJson(json));
        });
        return data;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return data;
      }

    }catch(e){
      return data;
    }
  }
   
}