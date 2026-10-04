class EndPoints {
  //*network assets==========
  static const String station =
      'https://readysetvr.com/wp-content/uploads/2021/11/blog_5-things-in-future-gas-stations-1536x749.jpg';
  //!============================== base url =====================
  static const String baseUrl = 'https://futureexpressappnergy.com.sa/api';

  //?============================== auth endpoints =====================

  static const String v3Login = 'https://future-ex.com/api/v3/login';
  static const String v3Profile = 'https://future-ex.com/api/v3/profile';
  static const String v3ProfileUpdate =
      'https://future-ex.com/api/v3/profile/update';
  static const String v3Logout = 'https://future-ex.com/api/v3/logout';
  static const String v3Orders = 'https://future-ex.com/api/v3/orders';
  static const String v3Statuses = 'https://future-ex.com/api/v3/statuses';
  static const String v3HomeSummary =
      'https://future-ex.com/api/v3/home-summary';
  static const String v3AppSettings =
      'https://future-ex.com/api/v3/App_setting';
  static const String v3ScanAndAssign =
      'https://future-ex.com/api/v3/orders/scan-and-assign';
  static String v3ConfirmOrderOtp(int id) =>
      'https://future-ex.com/api/v3/orders/confirm-otp/$id';
  static const String v3ScanOrder = 'https://future-ex.com/api/v3/scan-order';
  static const String v3MarkWhatsappSent =
      'https://future-ex.com/api/v3/scan-order/whatsapp/mark-sent';
  static const String v3ConfirmPickupFromCustomer =
      'https://future-ex.com/api/v3/return-pickup/confirm-from-customer';
  static const String v3ConfirmPickupFromMerchant =
      'https://future-ex.com/api/v3/return-pickup/confirm-from-merchant';
  static const String v3DailyReport =
      'https://future-ex.com/api/v3/daily-report';
  static const String v3SubmitDailyReport =
      'https://future-ex.com/api/v3/submit-daily-report';
  static const String v3Balance = 'https://future-ex.com/api/v3/balance';
  static const String v3UpdateShift =
      'https://future-ex.com/api/v3/update-shift';
}
