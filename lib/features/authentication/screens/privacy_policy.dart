import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final isEn = Get.locale?.languageCode == 'en';
    final bg = isDark ? const Color(0xFF111111) : const Color(0xFFF8F6F3);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFEEEBE6),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
        title: Text(
          isEn ? 'Privacy Policy' : 'Politique de confidentialité',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : const Color(0xFFEEEBE6),
            ),
          ),
          child: isEn
              ? _buildEnglish(context, isDark)
              : _buildFrench(context, isDark),
        ),
      ),
    );
  }

  Widget _buildEnglish(BuildContext context, bool isDark) {
    return _PolicyContent(isDark: isDark, sections: [
      _PolicySection(
        title: 'Last updated: May 2026',
        body: 'At OSHO, we are committed to protecting your personal data. This Privacy Policy explains how we collect, use and protect your information when you use our app.',
        isDate: true,
      ),
      _PolicySection(
        title: '1. Data We Collect',
        body: 'We collect the following information to provide our tailoring service:\n\n'
            '• Identity: first name, last name\n'
            '• Contact: email address, phone number\n'
            '• Measurements: body measurements saved in your profile\n'
            '• Delivery: shipping addresses\n'
            '• Payments: processed exclusively by Stripe — we never store your card details\n'
            '• Usage data: app interactions to improve our service',
      ),
      _PolicySection(
        title: '2. How We Use Your Data',
        body: 'Your data is used exclusively to:\n\n'
            '• Process and track your orders\n'
            '• Transmit your measurements to your assigned tailor\n'
            '• Manage delivery and logistics\n'
            '• Send order status notifications\n'
            '• Improve our service and user experience\n\n'
            'We never sell or share your data with third parties for commercial purposes.',
      ),
      _PolicySection(
        title: '3. Data Storage & Security',
        body: 'Your data is securely stored on Supabase servers with encryption in transit (HTTPS/TLS) and at rest. Payments are processed by Stripe, a PCI-DSS certified service. We apply strict access controls to limit who can view your information.',
      ),
      _PolicySection(
        title: '4. Measurement Data',
        body: 'Your body measurements are particularly sensitive data. They are:\n\n'
            '• Stored only in your personal profile\n'
            '• Shared only with the tailor assigned to your order\n'
            '• Never used for purposes other than tailoring your garment\n'
            '• Deletable at any time from your profile',
      ),
      _PolicySection(
        title: '5. Your Rights',
        body: 'You have the right to:\n\n'
            '• Access your personal data\n'
            '• Correct inaccurate data\n'
            '• Delete your account and all associated data\n'
            '• Withdraw consent at any time\n\n'
            'To exercise these rights, contact us at: privacy@osho.app',
      ),
      _PolicySection(
        title: '6. Cookies & Analytics',
        body: 'Our app may use anonymous analytical tools to understand how users interact with the service. No personal identification data is transmitted through these tools.',
      ),
      _PolicySection(
        title: '7. Contact',
        body: 'For any questions regarding this Privacy Policy:\n\nOSHO — privacy@osho.app',
      ),
    ]);
  }

  Widget _buildFrench(BuildContext context, bool isDark) {
    return _PolicyContent(isDark: isDark, sections: [
      _PolicySection(
        title: 'Dernière mise à jour : mai 2026',
        body: 'Chez OSHO, nous nous engageons à protéger vos données personnelles. Cette Politique de confidentialité explique comment nous collectons, utilisons et protégeons vos informations lorsque vous utilisez notre application.',
        isDate: true,
      ),
      _PolicySection(
        title: '1. Données collectées',
        body: 'Nous collectons les informations suivantes pour fournir notre service de confection :\n\n'
            '• Identité : prénom, nom de famille\n'
            '• Contact : adresse email, numéro de téléphone\n'
            '• Mensurations : mesures corporelles enregistrées dans votre profil\n'
            '• Livraison : adresses de livraison\n'
            '• Paiements : traités exclusivement par Stripe — nous ne stockons jamais vos données bancaires\n'
            '• Données d\'usage : interactions avec l\'app pour améliorer notre service',
      ),
      _PolicySection(
        title: '2. Utilisation de vos données',
        body: 'Vos données sont utilisées exclusivement pour :\n\n'
            '• Traiter et suivre vos commandes\n'
            '• Transmettre vos mensurations au tailleur assigné\n'
            '• Gérer la livraison et la logistique\n'
            '• Envoyer des notifications sur le statut de vos commandes\n'
            '• Améliorer notre service et votre expérience\n\n'
            'Nous ne vendons ni ne partageons jamais vos données avec des tiers à des fins commerciales.',
      ),
      _PolicySection(
        title: '3. Stockage et sécurité',
        body: 'Vos données sont stockées de manière sécurisée sur les serveurs Supabase avec chiffrement en transit (HTTPS/TLS) et au repos. Les paiements sont traités par Stripe, un service certifié PCI-DSS. Nous appliquons des contrôles d\'accès stricts pour limiter qui peut consulter vos informations.',
      ),
      _PolicySection(
        title: '4. Données de mensuration',
        body: 'Vos mensurations corporelles sont des données particulièrement sensibles. Elles sont :\n\n'
            '• Stockées uniquement dans votre profil personnel\n'
            '• Partagées uniquement avec le tailleur assigné à votre commande\n'
            '• Jamais utilisées à d\'autres fins que la confection de votre vêtement\n'
            '• Supprimables à tout moment depuis votre profil',
      ),
      _PolicySection(
        title: '5. Vos droits',
        body: 'Vous disposez du droit de :\n\n'
            '• Accéder à vos données personnelles\n'
            '• Corriger des données inexactes\n'
            '• Supprimer votre compte et toutes les données associées\n'
            '• Retirer votre consentement à tout moment\n\n'
            'Pour exercer ces droits, contactez-nous à : privacy@osho.app',
      ),
      _PolicySection(
        title: '6. Cookies et analytique',
        body: 'Notre application peut utiliser des outils analytiques anonymes pour comprendre comment les utilisateurs interagissent avec le service. Aucune donnée d\'identification personnelle n\'est transmise via ces outils.',
      ),
      _PolicySection(
        title: '7. Contact',
        body: 'Pour toute question concernant cette Politique de confidentialité :\n\nOSHO — privacy@osho.app',
      ),
    ]);
  }
}

// ── Terms & Conditions screen ─────────────────────────────────────────────────

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final isEn = Get.locale?.languageCode == 'en';
    final bg = isDark ? const Color(0xFF111111) : const Color(0xFFF8F6F3);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFEEEBE6),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
        title: Text(
          isEn ? 'Terms & Conditions' : 'Conditions générales',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : const Color(0xFFEEEBE6),
            ),
          ),
          child: isEn
              ? _buildEnglish(context, isDark)
              : _buildFrench(context, isDark),
        ),
      ),
    );
  }

  Widget _buildEnglish(BuildContext context, bool isDark) {
    return _PolicyContent(isDark: isDark, sections: [
      _PolicySection(
        title: 'Last updated: May 2026',
        body: 'By creating an account and using the OSHO application, you accept these Terms & Conditions in full. Please read them carefully before ordering.',
        isDate: true,
      ),
      _PolicySection(
        title: '1. Our Service',
        body: 'OSHO is a custom-made African fashion platform that connects customers with skilled artisan tailors. We offer:\n\n'
            '• Design and creation of made-to-measure garments\n'
            '• Order management and logistics\n'
            '• Measurement profile to personalise your creations',
      ),
      _PolicySection(
        title: '2. Orders',
        body: 'Every order placed on OSHO is a bespoke creation made specifically for you. Once payment is confirmed:\n\n'
            '• Your order is transmitted to a tailor from our network\n'
            '• Crafting begins within 24-48 hours\n'
            '• Estimated delivery time: 7 to 21 days depending on destination\n\n'
            'Orders cannot be modified once crafting has begun.',
      ),
      _PolicySection(
        title: '3. Prices & Payment',
        body: 'Prices displayed are in FCFA (XOF) or their USD equivalent depending on your language settings. Payments are processed securely by Stripe.\n\n'
            'Applicable taxes are calculated automatically according to your delivery country and are displayed before final validation.',
      ),
      _PolicySection(
        title: '4. Delivery',
        body: 'Shipping fees are calculated based on your delivery country. Delivery times are estimates and may vary depending on customs and local services. OSHO is not liable for delays caused by carriers or customs services.',
      ),
      _PolicySection(
        title: '5. Returns & Refunds',
        body: 'As each garment is made-to-measure for you, returns are only accepted in cases of:\n\n'
            '• Manufacturing defect attributable to OSHO\n'
            '• Item significantly different from the order\n\n'
            'In these cases, contact us within 7 days of receipt. We will offer alteration, exchange or full refund.',
      ),
      _PolicySection(
        title: '6. Measurements',
        body: 'You are responsible for the accuracy of the measurements you provide. OSHO cannot be held responsible for sizing issues resulting from incorrectly entered measurements. We recommend following our measurement guide carefully.',
      ),
      _PolicySection(
        title: '7. Intellectual Property',
        body: 'All content of the OSHO application (designs, images, interfaces) is protected by copyright. Any reproduction without prior written authorisation is prohibited.',
      ),
      _PolicySection(
        title: '8. Governing Law',
        body: 'These Terms & Conditions are governed by the laws of the Republic of Benin. Any dispute will be subject to the exclusive jurisdiction of Beninese courts.',
      ),
      _PolicySection(
        title: '9. Contact',
        body: 'OSHO — contact@osho.app',
      ),
    ]);
  }

  Widget _buildFrench(BuildContext context, bool isDark) {
    return _PolicyContent(isDark: isDark, sections: [
      _PolicySection(
        title: 'Dernière mise à jour : mai 2026',
        body: 'En créant un compte et en utilisant l\'application OSHO, vous acceptez pleinement ces Conditions générales. Veuillez les lire attentivement avant toute commande.',
        isDate: true,
      ),
      _PolicySection(
        title: '1. Notre service',
        body: 'OSHO est une plateforme de mode africaine sur mesure qui met en relation des clients avec des tailleurs artisans qualifiés. Nous proposons :\n\n'
            '• La conception et la création de vêtements sur mesure\n'
            '• La gestion des commandes et la logistique\n'
            '• Un profil de mensuration pour personnaliser vos créations',
      ),
      _PolicySection(
        title: '2. Commandes',
        body: 'Chaque commande passée sur OSHO est une création unique réalisée spécifiquement pour vous. Une fois le paiement confirmé :\n\n'
            '• Votre commande est transmise à un tailleur de notre réseau\n'
            '• La confection débute sous 24 à 48 heures\n'
            '• Délai de livraison estimé : 7 à 21 jours selon la destination\n\n'
            'Les commandes ne peuvent pas être modifiées une fois la confection commencée.',
      ),
      _PolicySection(
        title: '3. Prix et paiement',
        body: 'Les prix affichés sont en FCFA (XOF) ou leur équivalent en USD selon votre paramètre de langue. Les paiements sont traités de manière sécurisée par Stripe.\n\n'
            'Les taxes applicables sont calculées automatiquement selon votre pays de livraison et sont affichées avant la validation finale.',
      ),
      _PolicySection(
        title: '4. Livraison',
        body: 'Les frais de livraison sont calculés en fonction de votre pays de livraison. Les délais de livraison sont des estimations et peuvent varier selon les douanes et les services locaux. OSHO ne peut être tenu responsable des retards causés par les transporteurs ou services douaniers.',
      ),
      _PolicySection(
        title: '5. Retours et remboursements',
        body: 'Chaque vêtement étant confectionné sur mesure pour vous, les retours ne sont acceptés qu\'en cas de :\n\n'
            '• Défaut de fabrication imputable à OSHO\n'
            '• Article sensiblement différent de la commande\n\n'
            'Dans ces cas, contactez-nous dans les 7 jours suivant la réception. Nous proposerons une retouche, un échange ou un remboursement intégral.',
      ),
      _PolicySection(
        title: '6. Mensurations',
        body: 'Vous êtes responsable de l\'exactitude des mesures que vous fournissez. OSHO ne peut être tenu responsable des problèmes de taille résultant de mesures incorrectement saisies. Nous vous recommandons de suivre attentivement notre guide de mensuration.',
      ),
      _PolicySection(
        title: '7. Propriété intellectuelle',
        body: 'Tout le contenu de l\'application OSHO (designs, images, interfaces) est protégé par le droit d\'auteur. Toute reproduction sans autorisation écrite préalable est interdite.',
      ),
      _PolicySection(
        title: '8. Droit applicable',
        body: 'Ces conditions générales sont régies par le droit de la République du Bénin. Tout litige sera soumis à la juridiction exclusive des tribunaux béninois.',
      ),
      _PolicySection(
        title: '9. Contact',
        body: 'OSHO — contact@osho.app',
      ),
    ]);
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _PolicySection {
  final String title;
  final String body;
  final bool isDate;

  const _PolicySection({
    required this.title,
    required this.body,
    this.isDate = false,
  });
}

class _PolicyContent extends StatelessWidget {
  final bool isDark;
  final List<_PolicySection> sections;

  const _PolicyContent({
    required this.isDark,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((s) {
        if (s.isDate) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              s.title,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.body,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : const Color(0xFF6B6560),
                  height: 1.65,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
