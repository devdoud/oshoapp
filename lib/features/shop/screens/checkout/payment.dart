import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/features/authentication/screens/login/login.dart';

import 'package:osho/features/shop/controllers/checkout_controller.dart';
import 'package:osho/features/shop/controllers/stripe_controller.dart';
import 'package:osho/utils/constants/colors.dart';

import 'package:osho/utils/constants/image_strings.dart';

import 'package:osho/features/shop/controllers/customization_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final double? totalAmount;
  final bool isCart;

  const PaymentScreen({super.key, this.totalAmount, this.isCart = false});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selectedMethod = 0; // 0 for Mobile, 1 for Card
  int selectedMobileProvider = 0; // 0: MTN, 1: Celtiis, 2: Moov, 3: Orange

  final List<Map<String, String>> mobileProviders = [
    {'name': 'MTN Momo', 'image': OImages.mtnLogo},
    {'name': 'Celtiis Cash', 'image': OImages.celtiisLogo},
    {'name': 'Moov Money', 'image': OImages.moovLogo},
    {'name': 'Orange Money', 'image': OImages.orangeLogo},
  ];

  bool _ensureAuthenticated(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) return true;
    _showGuestBottomSheet(context);
    return false;
  }

  void _showGuestBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.lock, size: 32, color: OColors.primary),
            const SizedBox(height: 12),
            const Text(
              'Connexion requise',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Vous devez être connecté pour passer une commande.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.to(() => const LoginScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Se connecter',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Plus tard',
                  style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(StripeController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Paiement',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Options de paiement mobile",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(mobileProviders.length, (index) {
                    final provider = mobileProviders[index];
                    final isSelected =
                        selectedMethod == 0 && selectedMobileProvider == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMethod = 0;
                          selectedMobileProvider = index;
                        });
                      },
                      child: Container(
                        width: 85,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? OColors.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(provider['image']!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.contain),
                            ),
                            const SizedBox(height: 8),
                            Text(provider['name']!,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 32),

              // --- Card Payment Section ---
              const Text("Option de paiement par carte",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMethod = 1;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedMethod == 1
                          ? OColors.primary
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.credit_card,
                            color: Colors.black, size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Carte Bancaire / Apple Pay / Google Pay",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            Text("Paiement securise via Stripe",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      if (selectedMethod == 1)
                        const Icon(Icons.check_circle,
                            color: OColors.primary, size: 24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: OColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: Obx(() {
            final isLoading = CheckoutController.instance.isLoading.value;
            return isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Continuer",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                    ],
                  );
          }),
          onPressed: () {
            if (!_ensureAuthenticated(context)) return;

            // Calculate Total
            final total = widget.isCart
                ? (widget.totalAmount ?? 0)
                : (CustomizationController.instance.basePrice.value + 2000);

            if (selectedMethod == 1) {
              // Card Payment via Stripe (Payment Sheet)
              final stripeController = StripeController.instance;
              stripeController.makePayment(
                total,
                currency: 'XOF',
                isCart: widget.isCart,
              );
            } else {
              // Mobile Payment (Custom Logic or generic processOrder)
              if (widget.isCart) {
                CheckoutController.instance.processCartOrder(total);
              } else {
                CheckoutController.instance.processOrder(total);
              }
            }
          },
        ),
      ),
    );
  }
}

