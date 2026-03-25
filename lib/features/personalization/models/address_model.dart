class AddressModel {
  String? id;
  String userId;
  String fullName;
  String phone;
  String address;
  String city;
  String quartier;
  String? postalCode;
  String? country;
  bool isDefault;
  DateTime? createdAt;
  DateTime? updatedAt;

  AddressModel({
    this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.quartier,
    this.postalCode,
    this.country,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  AddressModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? quartier,
    String? postalCode,
    String? country,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      quartier: quartier ?? this.quartier,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'city': city,
      'quartier': quartier,
      'postal_code': postalCode,
      'country': country,
      'is_default': isDefault,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      quartier: json['quartier'] ?? '',
      postalCode: json['postal_code'],
      country: json['country'],
      isDefault: json['is_default'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  String get formattedAddress {
    final parts = <String>[
      address,
      quartier,
      city,
      if (postalCode != null && postalCode!.trim().isNotEmpty) postalCode!,
      if (country != null && country!.trim().isNotEmpty) country!,
    ];
    return parts.where((part) => part.trim().isNotEmpty).join(', ');
  }
}
