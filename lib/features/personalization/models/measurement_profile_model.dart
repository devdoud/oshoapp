class MeasurementProfileModel {
  String? id;
  String userId;
  String profileName;
  bool isPrimary;
  String gender;
  double? height;
  double? weight;
  double? chest;
  double? waist;
  double? hips;
  double? shoulder;
  double? sleeve;
  double? inseam;
  double? neck;

  MeasurementProfileModel({
    this.id,
    required this.userId,
    required this.profileName,
    this.isPrimary = false,
    this.gender = 'femme', // default
    this.height,
    this.weight,
    this.chest,
    this.waist,
    this.hips,
    this.shoulder,
    this.sleeve,
    this.inseam,
    this.neck,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'profile_name': profileName,
      'is_primary': isPrimary,
      'gender': gender,
      'height': height,
      'weight': weight,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'shoulder': shoulder,
      'sleeve': sleeve,
      'inseam': inseam,
      'neck': neck,
    };
  }

  factory MeasurementProfileModel.fromJson(Map<String, dynamic> json) {
    return MeasurementProfileModel(
      id: json['id'],
      userId: json['user_id'] ?? '',
      profileName: json['profile_name'] ?? 'Profil',
      isPrimary: json['is_primary'] ?? false,
      gender: json['gender'] ?? 'femme',
      height:
          json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight:
          json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      chest: json['chest'] != null ? (json['chest'] as num).toDouble() : null,
      waist: json['waist'] != null ? (json['waist'] as num).toDouble() : null,
      hips: json['hips'] != null ? (json['hips'] as num).toDouble() : null,
      shoulder: json['shoulder'] != null
          ? (json['shoulder'] as num).toDouble()
          : null,
      sleeve:
          json['sleeve'] != null ? (json['sleeve'] as num).toDouble() : null,
      inseam:
          json['inseam'] != null ? (json['inseam'] as num).toDouble() : null,
      neck: json['neck'] != null ? (json['neck'] as num).toDouble() : null,
    );
  }

  static MeasurementProfileModel empty() =>
      MeasurementProfileModel(userId: '', profileName: '');
}
