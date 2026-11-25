class Geo {
  const Geo({required this.lat, required this.lng});

  final double lat;
  final double lng;

  factory Geo.fromJson(Map<String, dynamic> json) {
    final lat = json['lat'] as String;
    final lng = json['lng'] as String;
    return Geo(
      lat: _parseCoordinate(lat, 'lat'),
      lng: _parseCoordinate(lng, 'lng'),
    );
  }

  static double _parseCoordinate(String text, String key) {
    final value = double.parse(text);
    if (!value.isFinite) throw FormatException('geo.$key must be finite');
    return value;
  }

  Map<String, Object?> toJson() => {
    'lat': lat.toString(),
    'lng': lng.toString(),
  };
}
