import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/filter_category_page.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/app/providers/home_provider.dart';
import 'package:webinar/app/providers/theme_provider.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/home_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/shimmer_component.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import '../../../../locator.dart';
import '../../../providers/app_language_provider.dart';
import '../../../../common/components.dart';
import '../../../providers/filter_course_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{

  String token = '';
  String name = '';

  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();

  late AnimationController appBarController;
  late Animation<double> appBarAnimation;

  double appBarHeight = 230;

  ScrollController scrollController = ScrollController();

  PageController sliderPageController = PageController();
  int currentSliderIndex = 0;
  
  PageController adSliderPageController = PageController();
  int currentAdSliderIndex = 0;

  

  @override
  void initState() {
    super.initState();

    getToken();

    appBarController = AnimationController(vsync: this,duration: const Duration(milliseconds: 200));
    appBarAnimation = Tween<double>(
      begin: 150 + MediaQuery.of(navigatorKey.currentContext!).viewPadding.top, 
      end: 80 + MediaQuery.of(navigatorKey.currentContext!).viewPadding.top, 
    ).animate(appBarController);

    scrollController.addListener(() {

      if(scrollController.position.pixels > 100){

        if(!appBarController.isAnimating){
          if(appBarController.status == AnimationStatus.dismissed){
            appBarController.forward();
          }
        }
      }else if(scrollController.position.pixels < 50){
        
        if(!appBarController.isAnimating){
          if(appBarController.status == AnimationStatus.completed){
            appBarController.reverse();
          }
        }

      }
    });


    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

      if(ModalRoute.of(context)!.settings.arguments != null){ 
        if(AppData.canShowFinalizeSheet){
          
          AppData.canShowFinalizeSheet = false;

          // finalize signup
          HomeWidget.showFinalizeRegister( (ModalRoute.of(context)!.settings.arguments as int) ).then((value) {
            if(value){
              getToken();
            }
          });

        }
      }

      if(locator<HomeProvider>().allDataIsEmpty()){
        locator<HomeProvider>().getData();
      }
    });

  }


  


  getToken()async{

    AppData.getAccessToken().then((value) {
      setState(() {
        token = value;
      });

      if(token.isNotEmpty){
        
        // get profile and save naem
        UserService.getProfile().then((value) async {
          if(value != null){            
            await AppData.saveName(value.fullName ?? '');
            getUserName();
          }
        });
        
      }
    });
    
    getUserName();
    
  }

  getUserName(){

    AppData.getName().then((value) {
      setState(() {
        name = value;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
   
    return Consumer<AppLanguageProvider>(
      builder: (context, languageProvider, _) {
        
        return directionality(
          child: Consumer<DrawerProvider>(
            builder: (context, drawerProvider, _) {

              context.watch<ThemeProvider>();
              
              return ClipRRect(
                borderRadius: borderRadius(radius:  drawerProvider.isOpenDrawer ? 20 : 0),
                child: Scaffold(
                  backgroundColor: backgroundColor,
                  body: Column(
                    children: [
                
                      // app bar
                      HomeWidget.homeAppBar(appBarController, appBarAnimation, token, searchController, searchNode, name),
                      
                
                      // body
                      Expanded(
                        child: Consumer<HomeProvider>(
                          builder: (context, homeProvider, _) {
                            return CustomScrollView(
                              controller: scrollController,
                              physics: const BouncingScrollPhysics(),
                                            
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Column(
                                    children: [
                                            
                                            
                                      // Featured Classes
                                      Column(
                                        children: [
                                          HomeWidget.titleAndMore(appText.featuredClasses, isViewAll: false),
                                            
                                          if(locator<HomeProvider>().featuredListData.isNotEmpty || homeProvider.isLoadingFeaturedListData)...{
                                            
                                            SizedBox(
                                              width: getSize().width,
                                              height: 215,
                                              child: PageView(
                                                controller: sliderPageController,
                                                onPageChanged: (value) async {
                                                  
                                                  await Future.delayed(const Duration(milliseconds: 500));
                                                  
                                                  setState(() {
                                                    currentSliderIndex = value;
                                                  });
                                                },
                                                physics: const BouncingScrollPhysics(),
                                                children: List.generate( homeProvider.isLoadingFeaturedListData ? 1 : homeProvider.featuredListData.length, (index) {
                                                  return homeProvider.isLoadingFeaturedListData
                                                  ? courseSliderItemShimmer()
                                                  : courseSliderItem(
                                                      homeProvider.featuredListData[index]
                                                    );
                                                }),
                                              ),
                                            ),
                                            
                                            space(10),
                                            
                                            // indecator
                                            SizedBox(
                                              width: getSize().width,
                                              height: 15,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  ...List.generate(homeProvider.featuredListData.length, (index) {
                                                    return AnimatedContainer(
                                                      duration: const Duration(milliseconds: 200),
                                                      width: currentSliderIndex == index ? 16 : 7,
                                                      height: 7,
                                                      margin: padding(horizontal: 2),
                                                      decoration: BoxDecoration(
                                                        color: green77(),
                                                        borderRadius: borderRadius()
                                                      ),
                                                    );
                                            
                                                  }),
                                                ],
                                              ),
                                            )
                                            
                                          },
                                        ],
                                      ),
                                            
                                            
                                      // Newest Classes
                                      Column(
                                        children: [
                                          HomeWidget.titleAndMore(appText.newestClasses, onTapViewAll: (){
                                            locator<FilterCourseProvider>().clearFilter();
                                            locator<FilterCourseProvider>().sort = 'newest';
                                            nextRoute(FilterCategoryPage.pageName);
                                          }),
                                            
                                          SizedBox(
                                            width: getSize().width,
                                            child: SingleChildScrollView(
                                              physics: const BouncingScrollPhysics(),
                                              padding: padding(),
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: List.generate( homeProvider.isLoadingNewsetListData ? 3 : homeProvider.newsetListData.length, (index) {
                                                  
                                                  return homeProvider.isLoadingNewsetListData
                                                    ? courseItemShimmer()
                                                    : courseItem(
                                                        homeProvider.newsetListData[index],
                                                      );
                                                }),
                                              ),
                                            ),
                                          )
                                            
                                        ],
                                      ),
                                            
                                            
                                      // Bundle
                                      Column(
                                        children: [
                                          HomeWidget.titleAndMore(appText.latestBundles, onTapViewAll: (){
                                            locator<FilterCourseProvider>().clearFilter();
                                            locator<FilterCourseProvider>().bundleCourse = true;
                                            nextRoute(FilterCategoryPage.pageName);
                                          }),
                                            
                                          SizedBox(
                                            width: getSize().width,
                                            child: SingleChildScrollView(
                                              physics: const BouncingScrollPhysics(),
                                              padding: padding(),
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: List.generate( homeProvider.isLoadingBundleData ? 3 : homeProvider.bundleData.length, (index) {
                                                  return homeProvider.isLoadingBundleData
                                                    ? courseItemShimmer()
                                                    : courseItem(
                                                        homeProvider.bundleData[index]
                                                      );
                                                }),
                                              ),
                                            ),
                                          )
                                            
                                        ],
                                      ),
                                            
                            
                                      if(homeProvider.bestRatedListData.isNotEmpty)...{
                            
                                        // Best Rated
                                        Column(
                                          children: [
                                              
                                            HomeWidget.titleAndMore(appText.bestRated, onTapViewAll: (){
                                              locator<FilterCourseProvider>().clearFilter();
                                              locator<FilterCourseProvider>().sort = 'best_rates';
                                              nextRoute(FilterCategoryPage.pageName);
                                            }),
                                              
                                            SizedBox(
                                              width: getSize().width,
                                              child: SingleChildScrollView(
                                                physics: const BouncingScrollPhysics(),
                                                padding: padding(),
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                  children: List.generate( homeProvider.isLoadingBestRatedListData ? 3 : homeProvider.bestRatedListData.length, (index) {
                                                    return homeProvider.isLoadingBestRatedListData
                                                      ? courseItemShimmer()
                                                      : courseItem(
                                                          homeProvider.bestRatedListData[index]
                                                        );
                                                  }),
                                                ),
                                              ),
                                            )
                                              
                                          ],
                                        ),
                                      },
                                            
                                      space(22),
                                            
                                      // by spending points
                                      Container(
                                        padding: padding(horizontal: 16),
                                        margin: padding(),
                                        width: getSize().width,
                                        height: 165,
                                            
                                        decoration: BoxDecoration(
                                          color: whiteFF_26,
                                          borderRadius: borderRadius(),
                                        ),
                                            
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                            
                                                Text(
                                                  appText.freeCourses,
                                                  style: style20Bold(),
                                                ),
                                            
                                                space(4),
                                                
                                                Text(
                                                  appText.bySpendingPoints,
                                                  style: style12Regular().copyWith(color: greyB2),
                                                ),
                                                
                                                space(8),
                                            
                                                button(
                                                  onTap: (){
                                                    locator<FilterCourseProvider>().clearFilter();
                                                    locator<FilterCourseProvider>().rewardCourse = true;
                                                    nextRoute(FilterCategoryPage.pageName);
                                                  }, 
                                                  width: 75, 
                                                  height: 32, 
                                                  text: appText.view, 
                                                  bgColor: green77(), 
                                                  textColor: Colors.white,
                                                  raduis: 10
                                                )
                                            
                                              ],
                                            ),
                                            
                                            
                                            
                                            SvgPicture.asset(AppAssets.pointsMedalSvg)
                                            
                                            
                                          ],
                                        ),
                                      ),
                                            
                                      space(10),
                                            
                                            
                                      // Best Selling
                                      Column(
                                        children: [
                                          HomeWidget.titleAndMore(appText.bestSelling, onTapViewAll: (){
                                            locator<FilterCourseProvider>().clearFilter();
                                            locator<FilterCourseProvider>().sort = 'bestsellers';
                                            nextRoute(FilterCategoryPage.pageName);
                                          }),
                                            
                                          SizedBox(
                                            width: getSize().width,
                                            child: SingleChildScrollView(
                                              physics: const BouncingScrollPhysics(),
                                              padding: padding(),
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: List.generate( homeProvider.isLoadingBestSellingListData ? 3 : homeProvider.bestSellingListData.length, (index) {
                                                  return homeProvider.isLoadingBestSellingListData
                                                    ? courseItemShimmer()
                                                    : courseItem(
                                                        homeProvider.bestSellingListData[index]
                                                      );
                                                }),
                                              ),
                                            ),
                                          )
                                            
                                        ],
                                      ),
                                      
                                            
                            
                                      if(homeProvider.isLoadingDiscountListData || homeProvider.discountListData.isNotEmpty)...{
                            
                                        // Discounted Classes
                                        Column(
                                          children: [
                                            HomeWidget.titleAndMore(appText.discountedClasses, onTapViewAll: (){
                                              locator<FilterCourseProvider>().clearFilter();
                                              locator<FilterCourseProvider>().discount = true;
                                              nextRoute(FilterCategoryPage.pageName);
                                            }),
                                              
                                            SizedBox(
                                              width: getSize().width,
                                              child: SingleChildScrollView(
                                                physics: const BouncingScrollPhysics(),
                                                padding: padding(),
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                  children: List.generate( homeProvider.isLoadingDiscountListData ? 3 : homeProvider.discountListData.length, (index) {
                                                    return homeProvider.isLoadingDiscountListData
                                                      ? courseItemShimmer()
                                                      : courseItem(
                                                          homeProvider.discountListData[index],
                                                        );
                                                  }),
                                                ),
                                              ),
                                            )
                                              
                                          ],
                                        ),
                                      },
                                            
                                      // Free Classes
                                      Column(
                                        children: [
                                          HomeWidget.titleAndMore(appText.freeClasses, onTapViewAll: (){
                                            locator<FilterCourseProvider>().clearFilter();
                                            locator<FilterCourseProvider>().free = true;
                                            nextRoute(FilterCategoryPage.pageName);
                                          }),
                                            
                                          SizedBox(
                                            width: getSize().width,
                                            child: SingleChildScrollView(
                                              physics: const BouncingScrollPhysics(),
                                              padding: padding(),
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: List.generate( homeProvider.isLoadingFreeListData ? 3 : homeProvider.freeListData.length, (index) {
                                                  return homeProvider.isLoadingFreeListData
                                                    ? courseItemShimmer()
                                                    : courseItem(
                                                        homeProvider.freeListData[index]
                                                      );
                                                }),
                                              ),
                                            ),
                                          )
                                            
                                        ],
                                      ),
                                            
                                            
                                            
                                      space(150),
                                            
                                    ],
                                  ),
                            
                                )
                              ],
                            );
                          }
                        )
                      )
                  
                    ],
                  ),
                ),
              );
            }
          )
        );
      }
    );
  }
}