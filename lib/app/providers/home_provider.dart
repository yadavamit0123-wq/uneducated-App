import 'package:flutter/material.dart';
import 'package:webinar/app/models/course_model.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/common/utils/currency_utils.dart';
import 'package:webinar/locator.dart';

class HomeProvider extends ChangeNotifier{


  
  bool isLoadingFeaturedListData=false;
  List<CourseModel> featuredListData = [];

  bool isLoadingNewsetListData=false;
  List<CourseModel> newsetListData = [];
  
  bool isLoadingBestRatedListData=false;
  List<CourseModel> bestRatedListData = [];
  
  bool isLoadingBestSellingListData=false;
  List<CourseModel> bestSellingListData = [];
  
  bool isLoadingDiscountListData=false;
  List<CourseModel> discountListData = [];
  
  bool isLoadingFreeListData=false;
  List<CourseModel> freeListData = [];
  
  bool isLoadingBundleData=false;
  List<CourseModel> bundleData = [];



  Future getData() async {

    await locator<CurrencyUtils>().init();

    isLoadingFeaturedListData = true;
    isLoadingBundleData=true;
    isLoadingNewsetListData = true;
    isLoadingBestRatedListData=true;
    isLoadingBestSellingListData=true;
    isLoadingDiscountListData=true;
    isLoadingFreeListData=true;
    notifyListeners();
    
    Future.wait(
      [
        getDeaturedCourseData(), 
        getBundleData(),
        getNewestData(),
        getBestRatesData(),
        getBestsellersData(),
        getDiscountData(),
        getFreeData(),
      ]
    ).then((v){
      notifyListeners();
    });
  }

  Future getDeaturedCourseData()async{
    
    await CourseService.featuredCourse().then((value) {
      
      isLoadingFeaturedListData = false;
      featuredListData = value;
    });
  }

  Future getBundleData()async{

    await CourseService.getAll(offset: 0, bundle: true).then((value) {
      
      isLoadingBundleData=false;
      bundleData = value;
    });

  }

  Future getNewestData()async{
    
    await CourseService.getAll(offset: 0, sort: 'newest').then((value) {
    
      isLoadingNewsetListData=false;
      newsetListData = value;
    });

  }

  Future getBestRatesData()async{

    await CourseService.getAll(offset: 0, sort: 'best_rates').then((value) {
    
      isLoadingBestRatedListData = false;
      bestRatedListData = value;
    });

  }

  Future getBestsellersData()async{
    await CourseService.getAll(offset: 0, sort: 'bestsellers').then((value) {
      
      isLoadingBestSellingListData = false;
      bestSellingListData = value;
    });
    
  }

  Future getDiscountData()async{
    
    await CourseService.getAll(offset: 0, discount: true).then((value) {
      
      isLoadingDiscountListData = false;
      discountListData = value;
    });
    
  }

  Future getFreeData()async{
    await CourseService.getAll(offset: 0, free: true).then((value) {
      
      isLoadingFreeListData = false;
      freeListData = value;
    });
  
  }



  bool allDataIsEmpty(){
    if(featuredListData.isEmpty && newsetListData.isEmpty && bestRatedListData.isEmpty && bestSellingListData.isEmpty && discountListData.isEmpty && freeListData.isEmpty && bundleData.isEmpty ){
      return true;
    }else{
      return false;
    }
  }
}