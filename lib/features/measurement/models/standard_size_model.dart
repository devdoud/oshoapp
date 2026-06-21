class StandardSize {
  final String size;
  final double? height;
  final double? weight;
  final double? chest;
  final double waist;
  final double? hips;
  final double neck;
  final double shoulder;
  final double sleeve;
  final double inseam;

  // New fields
  final double? upperArm;
  final double? backLength;
  final double? dressLength;
  final double? thigh;
  final double? trouserLength;
  final double? bustHeight;

  StandardSize({
    required this.size,
    this.height,
    this.weight,
    this.chest,
    required this.waist,
    this.hips,
    required this.neck,
    required this.shoulder,
    required this.sleeve,
    required this.inseam,
    this.upperArm,
    this.backLength,
    this.dressLength,
    this.thigh,
    this.trouserLength,
    this.bustHeight,
  });
}

class StandardSizes {
  // ── Tailles haut femme (XS → XXL) ──────────────────────────────────────────
  static final List<StandardSize> womenTopSizes = [
    StandardSize(size: 'XS', height: 160, weight: 50, chest: 80, waist: 62, hips: 88, neck: 30, shoulder: 36, sleeve: 57, inseam: 75, upperArm: 26, backLength: 37, dressLength: 130, bustHeight: 24),
    StandardSize(size: 'S',  height: 163, weight: 55, chest: 84, waist: 66, hips: 92, neck: 31, shoulder: 37, sleeve: 58, inseam: 76, upperArm: 27, backLength: 38, dressLength: 132, bustHeight: 25),
    StandardSize(size: 'M',  height: 166, weight: 60, chest: 88, waist: 70, hips: 96, neck: 32, shoulder: 38, sleeve: 59, inseam: 77, upperArm: 28, backLength: 39, dressLength: 134, bustHeight: 26),
    StandardSize(size: 'L',  height: 169, weight: 66, chest: 92, waist: 74, hips: 100, neck: 33, shoulder: 39, sleeve: 60, inseam: 78, upperArm: 30, backLength: 40, dressLength: 136, bustHeight: 27),
    StandardSize(size: 'XL', height: 172, weight: 72, chest: 96, waist: 78, hips: 104, neck: 34, shoulder: 40, sleeve: 61, inseam: 79, upperArm: 32, backLength: 41, dressLength: 138, bustHeight: 28),
    StandardSize(size: 'XXL',height: 175, weight: 78, chest: 100,waist: 82, hips: 108, neck: 35, shoulder: 41, sleeve: 62, inseam: 80, upperArm: 34, backLength: 42, dressLength: 140, bustHeight: 29),
  ];

  // ── Tailles bas femme (34 → 48 EU) ─────────────────────────────────────────
  static final List<StandardSize> womenBottomSizes = [
    StandardSize(size: '34', waist: 62, hips: 88,  neck: 30, shoulder: 36, sleeve: 57, inseam: 74, thigh: 50, trouserLength: 100),
    StandardSize(size: '36', waist: 66, hips: 92,  neck: 31, shoulder: 37, sleeve: 58, inseam: 75, thigh: 52, trouserLength: 101),
    StandardSize(size: '38', waist: 70, hips: 96,  neck: 32, shoulder: 38, sleeve: 59, inseam: 76, thigh: 54, trouserLength: 102),
    StandardSize(size: '40', waist: 74, hips: 100, neck: 33, shoulder: 39, sleeve: 60, inseam: 77, thigh: 56, trouserLength: 103),
    StandardSize(size: '42', waist: 78, hips: 104, neck: 34, shoulder: 40, sleeve: 61, inseam: 78, thigh: 58, trouserLength: 104),
    StandardSize(size: '44', waist: 82, hips: 108, neck: 35, shoulder: 41, sleeve: 62, inseam: 79, thigh: 60, trouserLength: 105),
    StandardSize(size: '46', waist: 86, hips: 112, neck: 36, shoulder: 42, sleeve: 62, inseam: 80, thigh: 62, trouserLength: 105),
    StandardSize(size: '48', waist: 90, hips: 116, neck: 37, shoulder: 43, sleeve: 63, inseam: 80, thigh: 64, trouserLength: 106),
    StandardSize(size: '50', waist: 94, hips: 120, neck: 38, shoulder: 44, sleeve: 63, inseam: 81, thigh: 66, trouserLength: 107),
  ];

  // ── Tailles haut homme (XS → XXL) ──────────────────────────────────────────
  static final List<StandardSize> menTopSizes = [
    StandardSize(size: 'XS', height: 165, weight: 58, chest: 88,  waist: 74, neck: 36, shoulder: 40, sleeve: 59, inseam: 76, upperArm: 30, backLength: 43, dressLength: 140),
    StandardSize(size: 'S',  height: 170, weight: 64, chest: 92,  waist: 78, neck: 37, shoulder: 41, sleeve: 60, inseam: 77, upperArm: 32, backLength: 44, dressLength: 142),
    StandardSize(size: 'M',  height: 175, weight: 70, chest: 96,  waist: 82, neck: 38, shoulder: 42, sleeve: 61, inseam: 78, upperArm: 34, backLength: 45, dressLength: 144),
    StandardSize(size: 'L',  height: 180, weight: 76, chest: 100, waist: 86, neck: 39, shoulder: 43, sleeve: 62, inseam: 79, upperArm: 36, backLength: 46, dressLength: 146),
    StandardSize(size: 'XL', height: 185, weight: 82, chest: 104, waist: 90, neck: 40, shoulder: 44, sleeve: 63, inseam: 80, upperArm: 38, backLength: 47, dressLength: 148),
    StandardSize(size: 'XXL',height: 190, weight: 88, chest: 108, waist: 94, neck: 41, shoulder: 45, sleeve: 64, inseam: 81, upperArm: 40, backLength: 48, dressLength: 150),
  ];

  // ── Tailles bas homme (30 → 48) ─────────────────────────────────────────────
  static final List<StandardSize> menBottomSizes = [
    StandardSize(size: '30', waist: 76,  hips: 90,  neck: 36, shoulder: 40, sleeve: 59, inseam: 76, thigh: 54, trouserLength: 100),
    StandardSize(size: '32', waist: 80,  hips: 94,  neck: 37, shoulder: 41, sleeve: 60, inseam: 77, thigh: 56, trouserLength: 102),
    StandardSize(size: '34', waist: 84,  hips: 98,  neck: 38, shoulder: 42, sleeve: 61, inseam: 78, thigh: 58, trouserLength: 103),
    StandardSize(size: '36', waist: 88,  hips: 102, neck: 39, shoulder: 43, sleeve: 62, inseam: 79, thigh: 60, trouserLength: 104),
    StandardSize(size: '38', waist: 92,  hips: 106, neck: 40, shoulder: 44, sleeve: 63, inseam: 80, thigh: 62, trouserLength: 105),
    StandardSize(size: '40', waist: 96,  hips: 110, neck: 41, shoulder: 45, sleeve: 64, inseam: 81, thigh: 64, trouserLength: 106),
    StandardSize(size: '42', waist: 100, hips: 114, neck: 42, shoulder: 46, sleeve: 65, inseam: 82, thigh: 66, trouserLength: 107),
    StandardSize(size: '44', waist: 104, hips: 118, neck: 43, shoulder: 47, sleeve: 65, inseam: 82, thigh: 68, trouserLength: 108),
    StandardSize(size: '46', waist: 108, hips: 122, neck: 44, shoulder: 48, sleeve: 66, inseam: 83, thigh: 70, trouserLength: 109),
    StandardSize(size: '48', waist: 112, hips: 126, neck: 45, shoulder: 49, sleeve: 66, inseam: 83, thigh: 72, trouserLength: 110),
  ];

  static List<StandardSize> getSizesByGender(String gender) =>
      gender.toLowerCase() == 'homme' ? menTopSizes : womenTopSizes;

  static List<StandardSize> getTopSizesByGender(String gender) =>
      gender.toLowerCase() == 'homme' ? menTopSizes : womenTopSizes;

  static List<StandardSize> getBottomSizesByGender(String gender) =>
      gender.toLowerCase() == 'homme' ? menBottomSizes : womenBottomSizes;
}
