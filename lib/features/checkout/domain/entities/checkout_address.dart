import 'package:equatable/equatable.dart';

class CheckoutAddress extends Equatable {
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  const CheckoutAddress({
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'US',
  });

  String get displayAddress =>
      '$addressLine1${addressLine2.isNotEmpty ? ', $addressLine2' : ''}, $city, $state $postalCode';

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'phone': phone,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
      };

  factory CheckoutAddress.fromMap(Map<String, dynamic> map) => CheckoutAddress(
        fullName: map['fullName'] ?? '',
        phone: map['phone'] ?? '',
        addressLine1: map['addressLine1'] ?? '',
        addressLine2: map['addressLine2'] ?? '',
        city: map['city'] ?? '',
        state: map['state'] ?? '',
        postalCode: map['postalCode'] ?? '',
        country: map['country'] ?? 'US',
      );

  @override
  List<Object?> get props => [fullName, phone, addressLine1, city, state, postalCode];
}
