import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/logistics_calculator.dart';

class LogisticsRatesCard extends StatelessWidget {
  const LogisticsRatesCard({
    super.key,
    required this.currentRate,
  });

  final LogisticsRate currentRate;

  @override
  Widget build(BuildContext context) {
    final rates = [
      OLogisticsCalculator.localRate,
      OLogisticsCalculator.africaRate,
      OLogisticsCalculator.europeRate,
      OLogisticsCalculator.northAmericaRate,
      OLogisticsCalculator.internationalRate,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OColors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: OColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.airplane,
                    color: OColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tarifs logistiques',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Calcules selon le pays et le poids estime du colis.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: OColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.location, color: OColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentRate.zone,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${currentRate.weightLabel} - ${currentRate.estimate}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  OLogisticsCalculator.formatFee(currentRate.fee),
                  style: const TextStyle(
                    color: OColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rates.map(_buildRateChip).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRateChip(LogisticsRate rate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${rate.zone}: ${OLogisticsCalculator.formatFee(rate.fee)}',
        style: const TextStyle(
          color: OColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
