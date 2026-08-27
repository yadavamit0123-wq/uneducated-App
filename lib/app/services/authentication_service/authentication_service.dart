import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:webinar/app/models/auth_login_result.dart';
import 'package:webinar/app/models/register_config_model.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/common/utils/error_handler.dart';
import 'package:webinar/common/utils/http_handler.dart';

class AuthenticationService {
  static Future google(String email, String token, String name) async {
    try {
      String url = '${Constants.baseUrl}google/callback';

      Response res = await httpPost(url, {
        'email': email,
        'name': name,
        'id': token,
      });

      if (res.statusCode == 200) {
        await _saveToken(jsonDecode(res.body)['data']['token']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future facebook(String email, String token, String name) async {
    try {
      String url = '${Constants.baseUrl}facebook/callback';

      Response res =
          await httpPost(url, {'id': token, 'name': name, 'email': email});

      var jsonResponse = parseCleanJson(res.body.toString());
      if (jsonResponse['success']) {
        await _saveToken(jsonResponse['data']['token']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static bool isEmail(String value) {
    return RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(value);
  }

  static String formatMobileUsername(String dialCode, String mobile) {
    final code = dialCode.replaceAll('+', '');
    final digits = mobile.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith(code)) {
      return digits;
    }
    return '$code$digits';
  }

  static Future<AuthLoginResult> login(String username, String password) async {
    try {
      String url = '${Constants.baseUrl}login';

      final loginUsername = isEmail(username)
          ? username
          : username.replaceAll(RegExp(r'\D'), '');

      Response res = await httpPost(url, {
        'username': loginUsername,
        'password': password,
      });

      var jsonResponse = parseCleanJson(res.body.toString());
      log(jsonResponse.toString());

      if (_hasLoginToken(jsonResponse)) {
        await _saveToken(jsonResponse['data']['token']);
        await AppData.saveName('');
        return AuthLoginResult.loggedIn();
      }

      if (jsonResponse['status'] == 'not_verified') {
        return AuthLoginResult.notVerified(
          username: loginUsername,
          isEmail: isEmail(username),
        );
      }

      ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
      return AuthLoginResult.failed();
    } catch (e) {
      return AuthLoginResult.failed();
    }
  }

  static Future<Map?> registerWithEmail(
      String registerMethod,
      String email,
      String password,
      String repeatPassword,
      String? accountType,
      List<Fields>? fields) async {
    try {
      String url = '${Constants.baseUrl}register/step/1';

      Map body = {
        'register_method': registerMethod,
        'country_code': null,
        'email': email,
        'password': password,
        'password_confirmation': repeatPassword,
      };

      if (fields != null) {
        Map bodyFields = {};
        for (var i = 0; i < fields.length; i++) {
          if (fields[i].type != 'upload') {
            bodyFields.addEntries({
              fields[i].id: (fields[i].type == 'toggle')
                  ? fields[i].userSelectedData == null
                      ? 0
                      : 1
                  : fields[i].userSelectedData
            }.entries);
          }
        }

        body.addEntries({'fields': bodyFields.toString()}.entries);
      }

      Response res = await httpPost(url, body);

      var jsonResponse = parseCleanJson(res.body.toString());

      if (_isRegisterStep1Success(jsonResponse)) {
        return {
          'user_id': jsonResponse['data']['user_id'],
          'step': jsonResponse['status'],
        };
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Map?> registerWithPhone(
      String countryCode,
      String mobile,
      String password,
      String repeatPassword,
      String? accountType,
      List<Fields>? fields) async {
    try {
      String url = '${Constants.baseUrl}register/step/1';

      Map body = {
        'mobile': mobile,
        'country_code': countryCode,
        'password': password,
        'password_confirmation': repeatPassword,
      };

      if (fields != null) {
        Map bodyFields = {};
        for (var i = 0; i < fields.length; i++) {
          if (fields[i].type != 'upload') {
            bodyFields.addEntries({
              fields[i].id: (fields[i].type == 'toggle')
                  ? fields[i].userSelectedData == null
                      ? 0
                      : 1
                  : fields[i].userSelectedData
            }.entries);
          }
        }

        body.addEntries({'fields': bodyFields.toString()}.entries);
      }

      Response res = await httpPost(url, body);

      var jsonResponse = parseCleanJson(res.body.toString());
      if (_isRegisterStep1Success(jsonResponse)) {
        return {
          'user_id': jsonResponse['data']['user_id'],
          'step': jsonResponse['status'],
        };
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Map?> forgetPassword(String? countryCode, String data) async {
    try {
      String url = '${Constants.baseUrl}forget-password';

      Response res = await httpPost(url, {
        'type': countryCode == null ? 'email' : 'mobile',
        if (countryCode == null) ...{
          'email': data,
        } else ...{
          'country_code': countryCode.startsWith('+') ? countryCode : '+$countryCode',
          'mobile': data,
        }
      });

      log(res.body.toString());

      var jsonResponse = parseCleanJson(res.body.toString());
      if (jsonResponse['success']) {
        ErrorHandler()
            .showError(ErrorEnum.success, jsonResponse, readMessage: true);

        if (countryCode == null && jsonResponse['data']?['token'] != null) {
          return {
            'email': data,
            'token': jsonResponse['data']['token'].toString(),
          };
        }

        return {'success': true};
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Register OTP — POST /register/step/2. Saves token on status "verified".
  static Future<AuthVerifyResult> verifyRegisterCode(
      int userId, String code) async {
    try {
      String url = '${Constants.baseUrl}register/step/2';

      Response res = await httpPost(url, {
        'user_id': userId.toString(),
        'code': code,
      });

      log(res.body.toString());

      var jsonResponse = parseCleanJson(res.body.toString());
      if (_isVerifiedResponse(jsonResponse)) {
        await _saveTokenIfPresent(jsonResponse);
        return AuthVerifyResult(
          success: true,
          userId: jsonResponse['data']?['user_id'] ?? userId,
        );
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return const AuthVerifyResult(success: false);
      }
    } catch (e) {
      return const AuthVerifyResult(success: false);
    }
  }

  /// Login OTP — POST /verification {username, code}. Saves data.token.
  static Future<bool> verifyOtp({
    required String username,
    required String code,
  }) async {
    try {
      String url = '${Constants.baseUrl}verification';

      Response res = await httpPost(url, {
        'username': isEmail(username)
            ? username
            : username.replaceAll(RegExp(r'\D'), ''),
        'code': code,
      });

      log(res.body.toString());

      var jsonResponse = parseCleanJson(res.body.toString());
      if (_isVerifiedResponse(jsonResponse)) {
        await _saveTokenIfPresent(jsonResponse);
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Resend OTP — POST /verification/resend {username OR user_id}
  static Future<bool> resendOtp({String? username, int? userId}) async {
    try {
      String url = '${Constants.baseUrl}verification/resend';

      final Map<String, String> body = {};
      if (username != null && username.isNotEmpty) {
        body['username'] = isEmail(username)
            ? username
            : username.replaceAll(RegExp(r'\D'), '');
      } else if (userId != null) {
        body['user_id'] = userId.toString();
      } else {
        return false;
      }

      Response res = await httpPost(url, body);
      var jsonResponse = parseCleanJson(res.body.toString());

      if (jsonResponse['success'] == true) {
        ErrorHandler()
            .showError(ErrorEnum.success, jsonResponse, readMessage: true);
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Email reset — POST /reset-password/{token}
  static Future<bool> resetPasswordEmail({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      String url = '${Constants.baseUrl}reset-password/$token';

      Response res = await httpPost(url, {
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      var jsonResponse = parseCleanJson(res.body.toString());
      if (jsonResponse['success'] == true) {
        ErrorHandler()
            .showError(ErrorEnum.success, jsonResponse, readMessage: true);
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> registerStep3(String name, {String referralCode = ''}) async {
    try {
      String url = '${Constants.baseUrl}register/step/3';

      Response res = await httpPostWithToken(
        url,
        {
          'full_name': name,
          if (referralCode.isNotEmpty) 'referral_code': referralCode,
        },
        isRedirectingStatusCode: false,
      );

      var jsonResponse = parseCleanJson(res.body.toString());
      if (jsonResponse['success'] == true || _hasLoginToken(jsonResponse)) {
        await _saveTokenIfPresent(jsonResponse);
        await AppData.saveName(name);
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static bool _isRegisterStep1Success(Map<String, dynamic> jsonResponse) {
    return jsonResponse['success'] == true ||
        jsonResponse['status'] == 'stored' ||
        jsonResponse['status'] == 'go_step_2' ||
        jsonResponse['status'] == 'go_step_3';
  }

  static bool _hasLoginToken(Map<String, dynamic> jsonResponse) {
    return jsonResponse['status'] == 'login' ||
        (jsonResponse['success'] == true &&
            jsonResponse['data']?['token'] != null);
  }

  static bool _isVerifiedResponse(Map<String, dynamic> jsonResponse) {
    return jsonResponse['status'] == 'verified' ||
        jsonResponse['success'] == true;
  }

  static Future<void> _saveTokenIfPresent(
      Map<String, dynamic> jsonResponse) async {
    final token = jsonResponse['data']?['token'];
    if (token != null && token.toString().isNotEmpty) {
      await _saveToken(token.toString());
    }
  }

  static Future<void> _saveToken(String token) async {
    await AppData.saveAccessToken(token);
  }
}

Map<String, dynamic> parseCleanJson(String response) {
  final int jsonStart = response.indexOf('{');

  if (jsonStart == -1) {
    throw Exception('Invalid response: No JSON found');
  }

  final String cleanJson = response.substring(jsonStart);

  return jsonDecode(cleanJson);
}
