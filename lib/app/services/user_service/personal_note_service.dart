import 'dart:io';

import 'package:http/http.dart';
import 'package:webinar/app/models/note_model.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/common/utils/error_handler.dart';
import 'package:webinar/common/utils/http_handler.dart';
import 'package:dio/dio.dart' as dio;

import '../authentication_service/authentication_service.dart';

class PersonalNoteService{


  static Future<bool> create(int courseId, int itemId, String desc, File? file, String type)async{
    
    try{
      String url = '${Constants.baseUrl}panel/webinars/personal-notes';

      dio.FormData formData = dio.FormData.fromMap({
        "course_id": courseId.toString(),
        "item_id": "$itemId",
        "item_type": type,
        "note": desc,
        
        if(file != null)...{
          "attachment": await dio.MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        }
      });
      
      dio.Response res = await dioPostWithToken(
        url,
        formData, 
        isRedirectingStatusCode: false
      );

      
      if(res.data['success']){
        ErrorHandler().showError(ErrorEnum.success, res.data,readMessage: true);
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, res.data);
        return false;
      }

    }on dio.DioException catch(e){
      print(e);
      return false;
    }
  }
  
  
  
  
  static Future<NoteModel?> getNote(int id, String type)async{
    
    try{
      String url = '${Constants.baseUrl}panel/webinars/personal-notes?item=$id&type=$type';


      Response res = await httpGetWithToken(url);

      var jsonResponse = parseCleanJson(res.body.toString());
      
      if(jsonResponse['success']){
        return NoteModel.fromJson(jsonResponse['data']);
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }

    }catch(e){
      return null;
    }
  }
  
  static Future<bool> delete(int id)async{
    
    try{
      String url = '${Constants.baseUrl}panel/webinars/personal-notes/delete/$id';

      Response res = await httpDeleteWithToken(
        url,
        {}, 
      );

      var jsonResponse = parseCleanJson(res.body.toString());


      if(jsonResponse['success']){
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }

    }catch(e){
      return false;
    }
  }

}