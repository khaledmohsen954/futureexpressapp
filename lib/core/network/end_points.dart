class EndPoints {
  //*network assets==========
  static const String station =
      'https://readysetvr.com/wp-content/uploads/2021/11/blog_5-things-in-future-gas-stations-1536x749.jpg';
  //!============================== base url =====================
  static const String baseUrl = 'https://futureexpressappnergy.com.sa/api';
  // static const String baseUrl = 'https://new.sairhub.com/api';
  static const String testUrl = 'https://sairhub.com/api';
  // Microservices Base URLs
  static const String authBaseUrl = 'https://users-auth.futureexpressappnergy.com.sa/api';
  static const String fuelOrderBaseUrl = 'https://fuel-order.futureexpressappnergy.com.sa/api';
  static const String settingsBaseUrl = 'https://settings.futureexpressappnergy.com.sa/api';
  static const String supportBaseUrl = 'https://support.futureexpressappnergy.com.sa/api';
  static const String notificationsBaseUrl =
      'https://notifications.futureexpressappnergy.com.sa/api';
  static const String serviceProviderBaseUrl =
      'https://serviceprovider.futureexpressappnergy.com.sa/api';

  //?============================== auth endpoints =====================
  static const String validateMobile = '$authBaseUrl/validate-mobile';
  static const String register = '$authBaseUrl/send-otp';
  static const String sendOtp = '$authBaseUrl/send-otp';
  static const String verifyOtp = '$authBaseUrl/verify-otp';
  static const String setPasswordFirstLogin = '$authBaseUrl/set-password-first-login';
  static const String login = '$authBaseUrl/app/login';
  static const String forgetPassword = '$authBaseUrl/forget-password';
  static const String resetPassword = '$authBaseUrl/reset-password';
  static const String logout = '$authBaseUrl/app/logout';
  static const String deleteAccount = '$authBaseUrl/users/delete-account';
  static const String users = 'users';
  static const String confirmAccount = '/set-user-data-for-registration';
  static const String userInfo = '$authBaseUrl/users/user-info';
  static const String updatePassword = '$authBaseUrl/users/update-password';
  static const String updateProfilePhoto = '$authBaseUrl/users/update-profile-photo';
  static const String updateFcmToken = '$authBaseUrl/users/update-fcm-token';
  static const String changeLanguage = '/users/change-language';
  static const String updateProfile = '$authBaseUrl/users/update-profile';
  static const String sendFeedback = '$supportBaseUrl/feedback';
  static const String aboutCompany = '$settingsBaseUrl/about-company';
  static const String termsConditions = '$settingsBaseUrl/terms-conditions';
  static const String privacy = '$settingsBaseUrl/privacy';
  static const String notifications = '$notificationsBaseUrl/users/list-notifications?is_read=1';
  static const String spUploadPumpImage = '$fuelOrderBaseUrl/service-providers/read-pump';

  //?======================== service provider endpoints =====================
  //*=============== service provider fuel orders =============================
  //static const String spScanFuelOrder = '/service-providers/fuel-orders/scan-vehicle-qrcode';
  static const String spScanFuelOrder =
      '$fuelOrderBaseUrl/service-providers/fuel-orders/scan-qrcode';
  static const String spCreateFuelOrder =
      '$fuelOrderBaseUrl/service-providers/fuel-orders/create-order';
  static const String spGetAllFuelOrder = '$fuelOrderBaseUrl/service-providers/fuel-orders';
  static String spGetPendingFuelOrder = '$fuelOrderBaseUrl/service-providers/fuel-orders';
  static String spGetSingleFuelOrder(int id) =>
      '$fuelOrderBaseUrl/service-providers/fuel-orders/$id';
  static const String spReceiveFuelOrder =
      '$fuelOrderBaseUrl/service-providers/fuel-orders/receive-order';
  static const String spSendOtpFuelOrder =
      '$fuelOrderBaseUrl/service-providers/fuel-orders/sent-otp-complete-order';
  static const String spCompleteFuelOrder =
      '$fuelOrderBaseUrl/service-providers/fuel-orders/complete-order';
  static const String spCancelFuelOrder =
      '$fuelOrderBaseUrl/service-providers/fuel-orders/cancel-order';
  static const String spScanPlate = '$fuelOrderBaseUrl/service-providers/read-plate';
  //*=============== service reports =============================
  static const String spDayReport =
      '$fuelOrderBaseUrl/service-providers/employee/day-report/fuel-orders';
  static const String spDayOrderReport = '$fuelOrderBaseUrl/service-providers/fuel-orders';
  static const String scanNFC = '$fuelOrderBaseUrl/service-providers/fuel-orders/scan-vehicle-nfc';

  static String detailsUser(int id) => '$users/$id';
  //*===============Driver stations=============================
  static const String driverfuelStations = '$serviceProviderBaseUrl/app/branches/list-with-fuel';
  static const String driverGetAllFuelOrder = '$fuelOrderBaseUrl/driver/fuel-orders';
  static const String driverCreateFuelOrder = '$fuelOrderBaseUrl/driver/create-fuel-orders';
  static String driverGetSingleFuelOrder(int id) => '$fuelOrderBaseUrl/driver/fuel-orders/$id';
  static const String driverFinishOrder = '$fuelOrderBaseUrl/driver/fuel-orders/finish-order';
}
