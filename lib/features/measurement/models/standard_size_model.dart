class StandardSize {
  final String size;
  final double? height;
  final double? weight;
  final double chest;
  final double waist;
  final double? hips;
  final double neck;
  final double shoulder;
  final double sleeve;
  final double inseam;

  StandardSize({
    required this.size,
    this.height,
    this.weight,
    required this.chest,
    required this.waist,
    this.hips,
    required this.neck,
    required this.shoulder,
    required this.sleeve,
    required this.inseam,
  });
}

class StandardSizes {
  // Tailles standard pour femmes
  static final List<StandardSize> womenSizes = [
    StandardSize(
      size: 'XS',
      height: 160,
      weight: 50,
      chest: 80,
      waist: 62,
      hips: 88,
      neck: 30,
      shoulder: 36,
      sleeve: 57,
      inseam: 75,
    ),
    StandardSize(
      size: 'S',
      height: 163,
      weight: 55,
      chest: 84,
      waist: 66,
      hips: 92,
      neck: 31,
      shoulder: 37,
      sleeve: 58,
      inseam: 76,
    ),
    StandardSize(
      size: 'M',
      height: 166,
      weight: 60,
      chest: 88,
      waist: 70,
      hips: 96,
      neck: 32,
      shoulder: 38,
      sleeve: 59,
      inseam: 77,
    ),
    StandardSize(
      size: 'L',
      height: 169,
      weight: 66,
      chest: 92,
      waist: 74,
      hips: 100,
      neck: 33,
      shoulder: 39,
      sleeve: 60,
      inseam: 78,
    ),
    StandardSize(
      size: 'XL',
      height: 172,
      weight: 72,
      chest: 96,
      waist: 78,
      hips: 104,
      neck: 34,
      shoulder: 40,
      sleeve: 61,
      inseam: 79,
    ),
    StandardSize(
      size: 'XXL',
      height: 175,
      weight: 78,
      chest: 100,
      waist: 82,
      hips: 108,
      neck: 35,
      shoulder: 41,
      sleeve: 62,
      inseam: 80,
    ),
  ];

  // Tailles standard pour hommes
  static final List<StandardSize> menSizes = [
    StandardSize(
      size: 'XS',
      height: 165,
      weight: 58,
      chest: 88,
      waist: 74,
      neck: 36,
      shoulder: 40,
      sleeve: 59,
      inseam: 76,
    ),
    StandardSize(
      size: 'S',
      height: 170,
      weight: 64,
      chest: 92,
      waist: 78,
      neck: 37,
      shoulder: 41,
      sleeve: 60,
      inseam: 77,
    ),
    StandardSize(
      size: 'M',
      height: 175,
      weight: 70,
      chest: 96,
      waist: 82,
      neck: 38,
      shoulder: 42,
      sleeve: 61,
      inseam: 78,
    ),
    StandardSize(
      size: 'L',
      height: 180,
      weight: 76,
      chest: 100,
      waist: 86,
      neck: 39,
      shoulder: 43,
      sleeve: 62,
      inseam: 79,
    ),
    StandardSize(
      size: 'XL',
      height: 185,
      weight: 82,
      chest: 104,
      waist: 90,
      neck: 40,
      shoulder: 44,
      sleeve: 63,
      inseam: 80,
    ),
    StandardSize(
      size: 'XXL',
      height: 190,
      weight: 88,
      chest: 108,
      waist: 94,
      neck: 41,
      shoulder: 45,
      sleeve: 64,
      inseam: 81,
    ),
  ];

  static List<StandardSize> getSizesByGender(String gender) {
    return gender.toLowerCase() == 'homme' ? menSizes : womenSizes;
  }

  static List<StandardSize> getTopSizesByGender(String gender) {
    return gender.toLowerCase() == 'homme' ? menSizes : womenSizes;
  }

  static List<StandardSize> getBottomSizesByGender(String gender) {
    return gender.toLowerCase() == 'homme' ? menSizes : womenSizes;
  }
}
