import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import 'package:osho/utils/helpers/logistics_calculator.dart';

class LogisticsRatesCard extends StatefulWidget {
  const LogisticsRatesCard({super.key, required this.currentRate});
  final LogisticsRate currentRate;

  @override
  State<LogisticsRatesCard> createState() => _LogisticsRatesCardState();
}

class _LogisticsRatesCardState extends State<LogisticsRatesCard> {
  bool _expanded = false;

  static const _zones = [
    _Zone('Bénin', '🇧🇯', Iconsax.home_2),
    _Zone('Afrique', '🌍', Iconsax.airplane),
    _Zone('Europe', '🌍', Iconsax.airplane),
    _Zone('US / Canada', '🌎', Iconsax.airplane),
    _Zone('International', '🌐', Iconsax.global),
  ];

  String _emoji(String zone) {
    for (final z in _zones) {
      if (zone.toLowerCase().contains(z.name.toLowerCase().split(' ')[0])) {
        return z.emoji;
      }
    }
    return '🌐';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final rate = widget.currentRate;

    final allRates = [
      OLogisticsCalculator.localRate,
      OLogisticsCalculator.africaRate,
      OLogisticsCalculator.europeRate,
      OLogisticsCalculator.northAmericaRate,
      OLogisticsCalculator.internationalRate,
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFEEEBE6),
        ),
      ),
      child: Column(
        children: [
          // ── Zone active ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icône zone
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: OColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(_emoji(rate.zone),
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(rate.zone,
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF34C759).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Actif',
                            style: TextStyle(
                              fontSize: 9, fontWeight: FontWeight.w700,
                              color: Color(0xFF34C759),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 3),
                      Row(children: [
                        Icon(Iconsax.timer_1, size: 11,
                            color: isDark ? Colors.white38 : const Color(0xFFB0AAA2)),
                        const SizedBox(width: 4),
                        Text(rate.estimate,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Iconsax.weight, size: 11,
                            color: isDark ? Colors.white38 : const Color(0xFFB0AAA2)),
                        const SizedBox(width: 4),
                        Text(rate.weightLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                // Prix
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      OLogisticsCalculator.formatFeeLocalized(rate.fee),
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: OColors.primary, letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text('livraison',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Séparateur + toggle ────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : const Color(0xFFF8F6F3),
                borderRadius: _expanded
                    ? BorderRadius.zero
                    : const BorderRadius.vertical(bottom: Radius.circular(18)),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF0EDE8),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.truck, size: 12,
                      color: isDark ? Colors.white38 : const Color(0xFFB0AAA2)),
                  const SizedBox(width: 6),
                  Text(
                    _expanded ? 'Masquer les tarifs' : 'Voir tous les tarifs',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : const Color(0xFF888480),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Iconsax.arrow_down_1, size: 11,
                        color: isDark ? Colors.white38 : const Color(0xFFB0AAA2)),
                  ),
                ],
              ),
            ),
          ),

          // ── Grille des zones (expandable) ──────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : const Color(0xFFF8F6F3),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Column(
                children: allRates.asMap().entries.map((entry) {
                  final r = entry.value;
                  final isActive = r.zone == rate.zone;
                  final isLast = entry.key == allRates.length - 1;
                  return _RateRow(
                    rate: r,
                    isActive: isActive,
                    isLast: isLast,
                    isDark: isDark,
                    emoji: _emoji(r.zone),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Zone row ──────────────────────────────────────────────────────────────────

class _RateRow extends StatelessWidget {
  const _RateRow({
    required this.rate,
    required this.isActive,
    required this.isLast,
    required this.isDark,
    required this.emoji,
  });

  final LogisticsRate rate;
  final bool isActive;
  final bool isLast;
  final bool isDark;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            // Emoji zone
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: isActive
                    ? OColors.primary.withValues(alpha: 0.10)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white),
                borderRadius: BorderRadius.circular(10),
                border: isActive
                    ? Border.all(
                        color: OColors.primary.withValues(alpha: 0.20))
                    : null,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
            // Zone + délai
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rate.zone,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? OColors.primary
                          : (isDark
                              ? Colors.white70
                              : const Color(0xFF4A4542)),
                    ),
                  ),
                  Text(rate.estimate,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? Colors.white38
                          : const Color(0xFFB0AAA2),
                    ),
                  ),
                ],
              ),
            ),
            // Prix
            Text(
              OLogisticsCalculator.formatFeeLocalized(rate.fee),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                    ? OColors.primary
                    : (isDark ? Colors.white54 : const Color(0xFF888480)),
                letterSpacing: -0.2,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: OColors.primary, shape: BoxShape.circle,
                ),
              ),
            ] else
              const SizedBox(width: 12),
          ],
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 44),
            child: Container(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF0EDE8),
            ),
          ),
      ],
    );
  }
}

// ── Zone metadata ─────────────────────────────────────────────────────────────

class _Zone {
  const _Zone(this.name, this.emoji, this.icon);
  final String name;
  final String emoji;
  final IconData icon;
}
