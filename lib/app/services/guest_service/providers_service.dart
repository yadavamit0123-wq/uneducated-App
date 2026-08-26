
import 'package:http/http.dart';
import 'package:webinar/app/models/category_model.dart';
import 'package:webinar/app/models/meeting_times_model.dart';
import 'package:webinar/app/models/profile_model.dart';
import 'package:webinar/app/models/user_model.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/error_handler.dart';

import '../../../common/utils/constants.dart';
import '../../../common/utils/http_handler.dart';
import '../authentication_service/authentication_service.dart';

class ProvidersService{


  static Future<List<UserModel>> getInstructors({List<CategoryModel> categories= const [], String? sort, bool availableForMeetings=false, bool freeMeetings=false, bool discount=false, bool downloadable=false})async{
    List<UserModel> data = [];
    try{

      String url = '${Constants.baseUrl}providers/instructors?p=';

      if(discount) url += '&discount=1';
      if(downloadable) url += '&downloadable=1';
      if(freeMeetings) url += '&free_meetings=1';
      if(availableForMeetings) url += '&available_for_meetings=1';

      if(sort != null) url += '&sort=$sort';

      if(categories.isNotEmpty){
        categories.forEach((element) {
          url += '&categories[]=${element.id}';
        });
      }


      Response res = await httpGet(url);
        
      var jsonRes = parseCleanJson(res.body.toString());

      if (jsonRes['success']) {
        jsonRes['data']['users'].forEach((json){
          data.add(UserModel.fromJson(json));
        });

        return data;
      }else{
        return data;
      }


    }catch(e){
      return data;
    }
  }

  static Future<List<UserModel>> getOrganizations({List<CategoryModel> categories= const [], String? sort, bool availableForMeetings=false, bool freeMeetings=false, bool discount=false, bool downloadable=false})async{
    List<UserModel> data = [];
    try{

      String url = '${Constants.baseUrl}providers/organizations?p=';

      if(discount) url += '&discount=1';
      if(downloadable) url += '&downloadable=1';
      if(freeMeetings) url += '&free_meetings=1';
      if(availableForMeetings) url += '&available_for_meetings=1';

      if(sort != null) url += '&sort=$sort';

      if(categories.isNotEmpty){
        categories.forEach((element) {
          url += '&categories[]=${element.id}';
        });
      }


      Response res = await httpGet(url);
        
      var jsonRes = parseCleanJson(res.body.toString());

      if (jsonRes['success']) {
        jsonRes['data']['users'].forEach((json){
          data.add(UserModel.fromJson(json));
        });

        return data;
      }else{
        return data;
      }


    }catch(e){
      return data;
    }
  }

  static Future<List<UserModel>> getConsultations({List<CategoryModel> categories= const [], String? sort, bool availableForMeetings=false, bool freeMeetings=false, bool discount=false, bool downloadable=false})async{
    List<UserModel> data = [];
    try{

      String url = '${Constants.baseUrl}providers/consultations?p=';

      if(discount) url += '&discount=1';
      if(downloadable) url += '&downloadable=1';
      if(freeMeetings) url += '&free_meetings=1';
      if(availableForMeetings) url += '&available_for_meetings=1';

      if(sort != null) url += '&sort=$sort';

      if(categories.isNotEmpty){
        categories.forEach((element) {
          url += '&categories[]=${element.id}';
        });
      }


      Response res = await httpGet(url);
        
      var jsonRes = parseCleanJson(res.body.toString());

      if (jsonRes['success']) {
        jsonRes['data']['users'].forEach((json){
          data.add(UserModel.fromJson(json));
        });

        return data;
      }else{
        return data;
      }


    }catch(e){
      return data;
    }
  }

  static Future<ProfileModel?> getUserProfile(int id) async {
    try{

      String url = '${Constants.baseUrl}users/$id/profile';
      print(url);


      Response res = await httpGetWithToken(url);
        
      var jsonRes = parseCleanJson(res.body.toString());

      if (jsonRes['success']) {
        return ProfileModel.fromJson(jsonRes['data']['user'], cashback: jsonRes['data']['cashbackRules']);
      }else{
        return null;
      }


    }catch(e){
      return null;
    }
  }

  static Future<bool> follow(int id, bool state) async {
    try{

      String url = '${Constants.baseUrl}panel/users/$id/follow';


      Response res = await httpPostWithToken(
        url,
        {
          'status' : state ? '1' : '0'
        }
      );
        
      var jsonRes = parseCleanJson(res.body.toString());
      print(jsonRes);

      if (jsonRes['success']) {
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonRes, readMessage: true);
        return false;
      }


    }catch(e){
      return false;
    }
  }

  static Future<MeetingTimesModel?> getMeetings(int id,String date) async {
    try{

      String url = '${Constants.baseUrl}users/$id/meetings?date=$date';

      print(url);
      
      Response res = await httpGetWithToken(url);
        
      var jsonRes = parseCleanJson(res.body.toString());

      // print(jsonRes);

      if (jsonRes['success']) {
        return MeetingTimesModel.fromJson(jsonRes['data']);
      }else{
        return null;
      }


    }catch(e){
      return null;
    }
  }

  static Future<bool> reserveMeeting(int timeId, String date, String meetingType, int studentCount, String description, {bool isSendStudentId=true}) async {
    try{

      String url = '${Constants.baseUrl}meetings/reserve';

      Response res = await httpPostWithToken(
        url,
        {
          "time_id" : timeId,
          "date" : date,
          "meeting_type" : meetingType,
          if(isSendStudentId)...{
            "student_count" : studentCount,
          },
          "description" : description
        }
      );

      var jsonRes = parseCleanJson(res.body.toString());

      if (jsonRes['success']) {
        showSnackBar(ErrorEnum.success, appText.successAddToCartDesc);
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonRes);
        return false;
      }


    }catch(e){
      return false;
    }
  }

  static Future<bool> sendMessage(int userId, String subject, String email, String description) async {
    try{

      String url = '${Constants.baseUrl}users/$userId/send-message';

      Response res = await httpPostWithToken(
        url,
        {
          "title" : subject,
          "email" : email,
          "description" : description
        }
      );

      var jsonRes = parseCleanJson(res.body.toString());

      if (jsonRes['success']) {
        showSnackBar(ErrorEnum.success, jsonRes['message'].toString(), );
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonRes, readMessage: true);
        return false;
      }


    }catch(e){
      return false;
    }
  }

  
}