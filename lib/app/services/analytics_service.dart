import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:webinar/app/models/cart_model.dart';
import 'package:webinar/app/models/tracking_analytics_config.dart';
import 'package:webinar/common/data/app_data.dart';

/// Analytics item payload shared across Firebase and Meta events.
class AnalyticsItem {
  final String itemId;
  final String itemName;
  final String category;
  final double price;
  final int quantity;

  const AnalyticsItem({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'item_category': category,
      'price': price,
      'quantity': quantity,
    };
  }
}

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  TrackingAnalyticsConfig? _config;
  FirebaseAnalytics? _firebaseAnalytics;
  FacebookAppEvents? _facebookAppEvents;
  bool _active = false;
  bool _consentDecided = false;

  /// GTM container ID from config (stored for reference; native GTM not used in Flutter).
  String? _gtmContainerId;

  Map<String, dynamic>? _pendingPurchase;

  bool get isActive => _active;

  TrackingAnalyticsConfig? get config => _config;

  String? get gtmContainerId => _gtmContainerId;

  bool get needsConsentPrompt =>
      _config?.trackingEnabled == true &&
      (_config?.respectCookieConsent ?? false) &&
      !_consentDecided;

  String get _currency => _config?.currency ?? 'INR';

  bool get _metaEnabled =>
      _active && (_config?.metaPixelId?.isNotEmpty ?? false);

  /// Called from splash after config API loads.
  Future<void> init(TrackingAnalyticsConfig? config) async {
    _config = config;
    _gtmContainerId = config?.gtmContainerId;

    if (config == null || !config.trackingEnabled) {
      _active = false;
      return;
    }

    final consent = await AppData.getAnalyticsConsent();
    _consentDecided = consent != null;

    if (config.respectCookieConsent && consent != true) {
      _active = false;
      return;
    }

    await _initializeProviders();
  }

  /// Called when user accepts/rejects cookie consent dialog.
  Future<void> setConsent(bool granted) async {
    await AppData.saveAnalyticsConsent(granted);
    _consentDecided = true;

    if (!granted || _config?.trackingEnabled != true) {
      await _disableProviders();
      return;
    }

    await _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    try {
      _firebaseAnalytics = FirebaseAnalytics.instance;
      await _firebaseAnalytics!.setAnalyticsCollectionEnabled(true);

      if (_config?.metaPixelId?.isNotEmpty ?? false) {
        _facebookAppEvents = FacebookAppEvents();
        await _facebookAppEvents!.setAutoLogAppEventsEnabled(true);
      }

      _active = true;
    } catch (e) {
      debugPrint('AnalyticsService init error: $e');
      _active = false;
    }
  }

  Future<void> _disableProviders() async {
    _active = false;
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
      await FacebookAppEvents().setAutoLogAppEventsEnabled(false);
    } catch (_) {}
    _firebaseAppEvents = null;
    _firebaseAnalytics = null;
  }

  /// Stores checkout context for purchase event on payment deep link.
  void setPendingPurchase({
    required String transactionId,
    required double value,
    required List<AnalyticsItem> items,
  }) {
    _pendingPurchase = {
      'transactionId': transactionId,
      'value': value,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }

  void clearPendingPurchase() {
    _pendingPurchase = null;
  }

  List<AnalyticsEventItem> _toFirebaseItems(List<AnalyticsItem> items) {
    return items
        .map(
          (item) => AnalyticsEventItem(
            itemId: item.itemId,
            itemName: item.itemName,
            itemCategory: item.category,
            price: item.price,
            quantity: item.quantity,
          ),
        )
        .toList();
  }

  /// Event: view_item — SingleCoursePage, CourseOverviewPage
  Future<void> logViewItem({
    required String itemId,
    required String itemName,
    required String category,
    required double price,
  }) async {
    if (!_active) return;

    final item = AnalyticsItem(
      itemId: itemId,
      itemName: itemName,
      category: category,
      price: price,
    );

    try {
      await _firebaseAnalytics?.logViewItem(
        currency: _currency,
        value: price,
        items: _toFirebaseItems([item]),
      );
    } catch (e) {
      debugPrint('Analytics view_item error: $e');
    }

    if (!_metaEnabled) return;

    try {
      await _facebookAppEvents?.logViewContent(
        id: itemId,
        type: category,
        price: price,
        currency: _currency,
      );
    } catch (e) {
      debugPrint('Meta logViewContent error: $e');
    }
  }

  /// Event: add_to_cart — CartService.add / CartService.store success
  Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required String category,
    required double price,
    int quantity = 1,
  }) async {
    if (!_active) return;

    final item = AnalyticsItem(
      itemId: itemId,
      itemName: itemName,
      category: category,
      price: price,
      quantity: quantity,
    );

    try {
      await _firebaseAnalytics?.logAddToCart(
        currency: _currency,
        value: price * quantity,
        items: _toFirebaseItems([item]),
      );
    } catch (e) {
      debugPrint('Analytics add_to_cart error: $e');
    }

    if (!_metaEnabled) return;

    try {
      await _facebookAppEvents?.logAddToCart(
        id: itemId,
        type: category,
        price: price,
        currency: _currency,
      );
    } catch (e) {
      debugPrint('Meta logAddToCart error: $e');
    }
  }

  /// Event: begin_checkout — CheckoutPage, CartPage web checkout
  Future<void> logBeginCheckout({
    required double value,
    required List<AnalyticsItem> items,
    String? transactionId,
  }) async {
    if (!_active) return;

    setPendingPurchase(
      transactionId: transactionId ?? 'pending',
      value: value,
      items: items,
    );

    try {
      await _firebaseAnalytics?.logBeginCheckout(
        currency: _currency,
        value: value,
        items: _toFirebaseItems(items),
      );
    } catch (e) {
      debugPrint('Analytics begin_checkout error: $e');
    }

    if (!_metaEnabled) return;

    try {
      await _facebookAppEvents?.logInitiatedCheckout(
        totalPrice: value,
        currency: _currency,
        contentType: 'product',
        contentId: items.isNotEmpty ? items.first.itemId : null,
        numItems: items.length,
      );
    } catch (e) {
      debugPrint('Meta logInitiatedCheckout error: $e');
    }
  }

  /// Event: purchase — CheckoutPage credit success, payment deep link
  Future<void> logPurchase({
    required String transactionId,
    required double value,
    required List<AnalyticsItem> items,
  }) async {
    if (!_active) return;

    try {
      await _firebaseAnalytics?.logPurchase(
        currency: _currency,
        value: value,
        transactionId: transactionId,
        items: _toFirebaseItems(items),
      );
    } catch (e) {
      debugPrint('Analytics purchase error: $e');
    }

    if (!_metaEnabled) return;

    try {
      await _facebookAppEvents?.logPurchase(
        amount: value,
        currency: _currency,
        parameters: {
          'order_id': transactionId,
          if (_config?.metaPixelId != null) 'meta_pixel_id': _config!.metaPixelId!,
        },
      );
    } catch (e) {
      debugPrint('Meta logPurchase error: $e');
    }

    clearPendingPurchase();
  }

  /// Event: purchase — fired from academyapp://payment-success deep link
  Future<void> logPurchaseFromPending() async {
    if (_pendingPurchase == null || !_active) return;

    final items = (_pendingPurchase!['items'] as List)
        .map(
          (e) => AnalyticsItem(
            itemId: e['item_id'].toString(),
            itemName: e['item_name'].toString(),
            category: e['item_category'].toString(),
            price: (e['price'] as num).toDouble(),
            quantity: (e['quantity'] as num?)?.toInt() ?? 1,
          ),
        )
        .toList();

    await logPurchase(
      transactionId: _pendingPurchase!['transactionId'].toString(),
      value: (_pendingPurchase!['value'] as num).toDouble(),
      items: items,
    );
  }

  /// Event: sign_up — RegisterPage, VerifyCodePage
  Future<void> logSignUp({required String method}) async {
    if (!_active) return;

    try {
      await _firebaseAnalytics?.logSignUp(signUpMethod: method);
    } catch (e) {
      debugPrint('Analytics sign_up error: $e');
    }

    if (!_metaEnabled) return;

    try {
      await _facebookAppEvents?.logCompletedRegistration(
        registrationMethod: method,
      );
    } catch (e) {
      debugPrint('Meta logCompletedRegistration error: $e');
    }
  }

  static List<AnalyticsItem> itemsFromCart(CartModel? cartData) {
    if (cartData?.items == null) return [];

    return cartData!.items!.map((item) {
      return AnalyticsItem(
        itemId: item.id?.toString() ?? '',
        itemName: item.title?.toString() ?? '',
        category: item.type?.toString() ?? 'course',
        price: (item.price ?? 0).toDouble(),
        quantity: item.quantity ?? 1,
      );
    }).toList();
  }
}
