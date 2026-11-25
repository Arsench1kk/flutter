class Geo {
  const Geo({required this.lat, required this.lng});

  final double lat;
  final double lng;

  factory Geo.fromJson(Map<String, dynamic> json) => Geo(
    lat: _parseCoordinate(json, 'lat'),
    lng: _parseCoordinate(json, 'lng'),
  );

  static double _parseCoordinate(Map<String, dynamic> json, String key) {
    final value = double.parse(json[key] as String);
    if (!value.isFinite) throw FormatException('geo.$key must be finite');
    return value;
  }

  Map<String, Object?> toJson() => {
    'lat': lat.toString(),
    'lng': lng.toString(),
  };
}

class Address {
  const Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    street: json['street'] as String,
    suite: json['suite'] as String,
    city: json['city'] as String,
    zipcode: json['zipcode'] as String,
    geo: Geo.fromJson(json['geo'] as Map<String, dynamic>),
  );

  Map<String, Object?> toJson() => {
    'street': street,
    'suite': suite,
    'city': city,
    'zipcode': zipcode,
    'geo': geo.toJson(),
  };
}

class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    this.website,
    required this.address,
    required this.company,
    required this.companyBusiness,
  });

  const User.draft({
    required this.name,
    required this.username,
    required this.email,
  }) : id = 0,
       phone = '',
       website = null,
       address = const Address(
         street: '',
         suite: '',
         city: '',
         zipcode: '',
         geo: Geo(lat: 0, lng: 0),
       ),
       company = (name: '', catchPhrase: ''),
       companyBusiness = '';

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String? website;
  final Address address;
  final ({String name, String catchPhrase}) company;
  final String companyBusiness;

  static final _phonePunctuation = RegExp(r'[^0-9+]');

  String get phoneDigits => phone.replaceAll(_phonePunctuation, '');

  factory User.fromJson(Map<String, dynamic> json) {
    final company = json['company'] as Map<String, dynamic>;
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String?,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      company: (
        name: company['name'] as String,
        catchPhrase: company['catchPhrase'] as String,
      ),
      companyBusiness: company['bs'] as String,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'phone': phone,
    'website': website,
    'address': address.toJson(),
    'company': {
      'name': company.name,
      'catchPhrase': company.catchPhrase,
      'bs': companyBusiness,
    },
  };

  @override
  bool operator ==(Object other) => other is User && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User($id, $name)';
}
