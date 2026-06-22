class AppConstants {
  AppConstants._();

  // App Info
  static const String appName        = 'HA E-Commerce';
  static const String appVersion     = '1.0.0';
  static const String appBundleId    = 'com.ha.ecommerce';

  // Firestore Collections
  static const String usersCollection        = 'users';
  static const String productsCollection     = 'products';
  static const String categoriesCollection   = 'categories';
  static const String ordersCollection       = 'orders';
  static const String cartCollection         = 'carts';
  static const String reviewsCollection      = 'reviews';
  static const String bannersCollection      = 'banners';
  static const String addressesCollection    = 'addresses';
  static const String notificationsCollection= 'notifications';
  static const String wishlistCollection     = 'wishlists';
  static const String analyticsCollection    = 'analytics';
  static const String adminRolesCollection   = 'admin_roles';
  static const String flashSalesCollection   = 'flash_sales';
  static const String couponsCollection      = 'coupons';

  // Firebase Storage Paths
  static const String productImagesPath   = 'products';
  static const String userAvatarsPath     = 'avatars';
  static const String bannerImagesPath    = 'banners';
  static const String categoryImagesPath  = 'categories';

  // Pagination
  static const int defaultPageSize    = 20;
  static const int cartMaxQuantity    = 99;

  // Cache
  static const Duration cacheExpiry   = Duration(hours: 24);
  static const String cacheKeyPrefix  = 'ha_cache_';

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);

  // Order Status
  static const String orderPending    = 'pending';
  static const String orderConfirmed  = 'confirmed';
  static const String orderProcessing = 'processing';
  static const String orderShipped    = 'shipped';
  static const String orderDelivered  = 'delivered';
  static const String orderCancelled  = 'cancelled';
  static const String orderRefunded   = 'refunded';

  // User Roles
  static const String roleSuperAdmin   = 'super_admin';
  static const String roleAdmin        = 'admin';
  static const String roleProductManager = 'product_manager';
  static const String roleSupportAgent = 'support_agent';
  static const String roleCustomer     = 'customer';

  // Product Status
  static const String productActive   = 'active';
  static const String productInactive = 'inactive';
  static const String productDraft    = 'draft';

  // Payment Methods
  static const String paymentCOD      = 'cash_on_delivery';
  static const String paymentCard     = 'card';
  static const String paymentWallet   = 'wallet';

  // Shared Prefs Keys
  static const String keyThemeMode    = 'theme_mode';
  static const String keyUserId       = 'user_id';
  static const String keyOnboarding   = 'onboarding_done';
  static const String keyFcmToken     = 'fcm_token';
}
