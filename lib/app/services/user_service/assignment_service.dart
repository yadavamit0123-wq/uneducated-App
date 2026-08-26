import 'dart:io';

import 'package:http/http.dart';
import 'package:webinar/app/models/assignment_model.dart';
import 'package:webinar/app/models/instructor_assignment_model.dart';
import 'package:webinar/common/utils/http_handler.dart';
import '../../../common/enums/error_enum.dart';
import '../../../common/utils/constants.dart';
import '../../../common/utils/error_handler.dart';
import '../../models/chat_model.dart';
import 'package:dio/dio.dart' as dio;

import '../authentication_service/authentication_service.dart';

class AssignmentService{

  static Future<List<AssignmentModel>> getAssignments()async{
    List<AssignmentModel> data = [];
    try{
      String url = '${Constants.baseUrl}panel/my_assignments';


      Response res = await httpGetWithToken(
        url, 
      );


      var jsonResponse = parseCleanJson(res.body.toString());
      
      if(jsonResponse['success']){
        jsonResponse['data']['assignments'].forEach((json){
          data.add(AssignmentModel.fromJson(json));
        });
        
        return data;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return data;
      }

    }catch(e){
      return data;
    }
  }


  static Future<InstructorAssignmentModel?> getAllAssignmentsInstructor()async{
    try{
      String url = '${Constants.baseUrl}instructor/assignments';


      Response res = await httpGetWithToken(
        url, 
      );
      

      var jsonResponse = parseCleanJson(res.body.toString());
      if(jsonResponse['success']){

        return InstructorAssignmentModel.fromJson(jsonResponse['data']);
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }

    }catch(e){
      return null;
    }
  }
  
  static Future<List<AssignmentModel>> getStudents(int assignmentId)async{
    List<AssignmentModel> data = [];

    try{
      String url = '${Constants.baseUrl}instructor/assignments/$assignmentId/students';


      Response res = await httpGetWithToken(
        url, 
      );
      

      var jsonResponse = parseCleanJson(res.body.toString());
      if(jsonResponse['success']){
        jsonResponse['data'].forEach((json){
          data.add(AssignmentModel.fromJson(json));
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
  
  
  static Future<bool> setGrade(int historyId, int grade)async{

    try{
      String url = '${Constants.baseUrl}instructor/assignments/histories/$historyId/rate';

      Response res = await httpPostWithToken(
        url, 
        {
          "grade": grade
        }
      );
      

      var jsonResponse = parseCleanJson(res.body.toString());

      if(jsonResponse['success']){
        ErrorHandler().showError(ErrorEnum.success, jsonResponse,readMessage: true);
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }

    }catch(e){
      // print(e);
      return false;
    }
  }
  

  static Future<List<ChatModel>> getHistory(int assignmentId, int studentId)async{
    List<ChatModel> data = [];

    try{
      String url = '${Constants.baseUrl}panel/assignments/$assignmentId/messages?student_id=$studentId';

      Response res = await httpGetWithToken(
        url, 
      );
      

      var jsonResponse = parseCleanJson(res.body.toString());
      if(jsonResponse['success']){
        jsonResponse['data'].forEach((json){
          data.add(ChatModel.fromJson(json));
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
  
  
  static Future<bool> newQuestion(int id, String fileTitle, String desc,File? file, int studentId)async{
    
    try{
      
      String url = '${Constants.baseUrl}panel/assignments/$id/messages';

      dio.FormData formData = dio.FormData.fromMap({
        'message' : desc,
        'file_title' : '',
        'file_path': '',
        'student_id': studentId,
        
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

    }catch(e){
      return false;
    }
    
  }

  
  
}