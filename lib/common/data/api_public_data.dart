
import 'package:webinar/app/models/currency_model.dart';
import 'package:webinar/app/models/tracking_analytics_config.dart';

class PublicData{

  static dynamic apiConfigData;
  static TrackingAnalyticsConfig? trackingAnalyticsConfig;
  static List<CurrencyModel> currencyListData = [];
  static List<String> reasonsData = [];

  static String teacherRole = 'teacher';
  static String userRole = 'user';
  static String organizationRole = 'organization';
}
