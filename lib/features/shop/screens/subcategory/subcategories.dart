import 'package:flutter/material.dart';
import 'package:osho/common/widgets/appbar/appbar.dart';
import 'package:osho/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:osho/features/shop/models/product_model.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/device/device_utility.dart';

class SubcategoriesScreen extends StatelessWidget {
  const SubcategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OAppBar(
        title: Text("Agbada", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
        subTitle: Text("Liste des modèles", style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: Color(0xFF5E5E5E))),
        showBackArrow: true,
        actions: [
          InkWell(
            onTap: (){
              showDialog(
                context: context, 
                barrierDismissible: true,
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(OSizes.defaultPadding),
                  child: Dialog(
                    insetPadding: EdgeInsets.zero, // enlève la marge par défaut
                    backgroundColor: Colors.transparent,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(OSizes.defaultSpace),
                          decoration: BoxDecoration(
                          color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16), bottom: Radius.circular(16)),
                          ),
                          child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Vous êtes sur le point d’ajoutez un modèle de votre choix.",
                                    textAlign: TextAlign.left,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Color(0xFF181818)),
                                  ),
                                  const SizedBox(height: OSizes.sm),
                                  Text(
                                    "Notre équipe support vous communiquera le prix de votre modèle après avoir analysé les détails.",
                                    textAlign: TextAlign.left,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: Color(0xFF5E5E5E)),
                                  ),
                                  const SizedBox(height: OSizes.defaultSpace,),

                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        // Get.to(() => const CustomModelStep1());
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        backgroundColor: OColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text('Ajouter une image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                                    ),
                                  ),

                                ],
                          )
                    ),
                  )
                )
              )
              );
            },
            child: Image(image: AssetImage(OImages.addsquare), width: 24, height: 24,)
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(OSizes.defaultPadding),
          child: GridView.builder(
            itemCount: 10,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: OSizes.gridViewSpacing,
              crossAxisSpacing: OSizes.gridViewSpacing,
              mainAxisExtent: ODeviceUtils.getScreenHeight() * 0.28,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (_, index) => OProductCardVertical(product: ProductModel.empty()),
          ),
        ),
      ),
    );
  }
}