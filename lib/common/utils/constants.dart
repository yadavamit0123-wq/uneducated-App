import 'package:flutter/material.dart';

class Constants {
  
  
  static const dommain = 'https://uneducated.co.in';
  static const baseUrl = '$dommain/api/development/';
  // Set from Admin → Mobile App settings
  static const apiKey = '123456';
  static const scheme = 'academyapp';
  
  static final RouteObserver<ModalRoute<void>> singleCourseRouteObserver = RouteObserver<ModalRoute<void>>();
  static final RouteObserver<ModalRoute<void>> contentRouteObserver = RouteObserver<ModalRoute<void>>();

}
