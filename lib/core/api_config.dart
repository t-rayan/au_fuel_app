class ApiConfig {
  static const String baseUrl =
      "https://fppdirectapi-prod.fuelpricesqld.com.au";

  // Replace XXXXXXXX with your actual Subscriber Token from the Postman file
  static const String subscriberToken = "f477b753-ce77-4aac-8b50-b72775f3fbc4";

  static Map<String, String> get headers => {
    'Authorization': 'FPDAPI SubscriberToken=$subscriberToken',
    'Content-Type': 'application/json',
  };
}
