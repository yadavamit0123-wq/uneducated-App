class TrackingAnalyticsConfig {
  final bool trackingEnabled;
  final String? gtmContainerId;
  final String? metaPixelId;
  final String? clarityProjectId;
  final bool respectCookieConsent;
  final String? marketingCookieSlug;
  final String? currency;

  const TrackingAnalyticsConfig({
    required this.trackingEnabled,
    this.gtmContainerId,
    this.metaPixelId,
    this.clarityProjectId,
    required this.respectCookieConsent,
    this.marketingCookieSlug,
    this.currency,
  });

  factory TrackingAnalyticsConfig.fromJson(Map<String, dynamic> json) {
    return TrackingAnalyticsConfig(
      trackingEnabled: json['tracking_enabled'] == true,
      gtmContainerId: json['gtm_container_id']?.toString(),
      metaPixelId: json['meta_pixel_id']?.toString(),
      clarityProjectId: json['clarity_project_id']?.toString(),
      respectCookieConsent: json['respect_cookie_consent'] == true,
      marketingCookieSlug: json['marketing_cookie_slug']?.toString(),
      currency: json['currency']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tracking_enabled': trackingEnabled,
      'gtm_container_id': gtmContainerId,
      'meta_pixel_id': metaPixelId,
      'clarity_project_id': clarityProjectId,
      'respect_cookie_consent': respectCookieConsent,
      'marketing_cookie_slug': marketingCookieSlug,
      'currency': currency,
    };
  }
}
