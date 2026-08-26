import 'package:webinar/app/pages/main_page/home_page/payment_status_page/payment_status_page.dart';
import 'package:webinar/app/services/analytics_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/utils/constants.dart';

bool isPaymentSuccessDeepLink(Uri uri) {
  return uri.scheme == Constants.scheme && uri.host == 'payment-success';
}

bool isPaymentFailedDeepLink(Uri uri) {
  return uri.scheme == Constants.scheme && uri.host == 'payment-failed';
}

/// Logs purchase analytics for payment success deep links.
void handlePaymentAnalytics(Uri uri) {
  if (isPaymentSuccessDeepLink(uri)) {
    // Event: purchase — payment redirect from web checkout
    AnalyticsService.instance.logPurchaseFromPending();
  }
}

/// Handles academyapp://payment-success and academyapp://payment-failed deep links.
void handlePaymentDeepLink(Uri uri, {bool navigate = true}) {
  if (isPaymentSuccessDeepLink(uri)) {
    handlePaymentAnalytics(uri);
    if (navigate) {
      nextRoute(PaymentStatusPage.pageName, arguments: 'success');
    }
  } else if (isPaymentFailedDeepLink(uri)) {
    if (navigate) {
      nextRoute(PaymentStatusPage.pageName, arguments: 'failed');
    }
  }
}
