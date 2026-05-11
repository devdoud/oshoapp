class LogisticsRateModel {
  final int id;
  final String zone;
  final String zoneLabel;
  final int maxItems;
  final String weightLabel;
  final double fee;
  final String estimate;
  final String sourceLabel;
  final int sortOrder;

  const LogisticsRateModel({
    required this.id,
    required this.zone,
    required this.zoneLabel,
    required this.maxItems,
    required this.weightLabel,
    required this.fee,
    required this.estimate,
    required this.sourceLabel,
    this.sortOrder = 0,
  });

  factory LogisticsRateModel.fromJson(Map<String, dynamic> json) {
    return LogisticsRateModel(
      id: json['id'] as int,
      zone: json['zone'] as String,
      zoneLabel: json['zone_label'] as String,
      maxItems: json['max_items'] as int,
      weightLabel: json['weight_label'] as String,
      fee: (json['fee'] as num).toDouble(),
      estimate: json['estimate'] as String,
      sourceLabel: json['source_label'] as String,
      sortOrder: (json['sort_order'] as int?) ?? 0,
    );
  }
}
