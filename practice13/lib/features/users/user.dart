import 'address.dart';
import 'geo.dart';

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
