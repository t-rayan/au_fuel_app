class Locality {
  final String suburb;
  final String postcode;
  final String state;
  final double lat;
  final double lng;

  Locality({
    required this.suburb,
    required this.postcode,
    required this.state,
    required this.lat,
    required this.lng,
  });

  factory Locality.fromJson(Map<String, dynamic> json) {
    return Locality(
      suburb: json['suburb']?.toString() ?? '',
      postcode: json['postcode']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  String get displayName => "$suburb, $postcode, $state";
}
