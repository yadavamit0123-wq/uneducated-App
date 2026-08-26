import 'package:flutter/material.dart';
import 'package:webinar/common/data/app_data.dart';

class ThemeProvider extends ChangeNotifier {

  bool isLightMode = true;
  
  ThemeProvider(){
    AppData.getIsLightMode().then((value){
      isLightMode = value;
      notifyListeners();
    });
  }




  setTheme(bool isDark) async {
    isLightMode = isDark ? false : true;
    AppData.saveIsLightMode(isLightMode);
    notifyListeners();
  }

}