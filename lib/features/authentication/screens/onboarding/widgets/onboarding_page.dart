import 'package:flutter/material.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/helpers/helper_functions.dart';


class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key, required this.image, required this.title, required this.subTitle, required this.rectangleImage, this.subTitle2 = '', this.subTitle3 = '',
  });

  final String image, rectangleImage, title, subTitle, subTitle2, subTitle3;

  @override
  Widget build(BuildContext context) {
    return Stack(  
      children: [
        Transform.translate(
          offset: const Offset(0, 150),
          child: Transform.scale(
            scale: 1.4,
            child: SizedBox(
              width: OHelperFunctions.screenWidth(),
              height: OHelperFunctions.screenHeight(),
              child: Image(
                fit: BoxFit.cover,
                image: AssetImage(image),
              ),
          ),
          )
        ),
        Stack(
          children: [
            Transform.translate(
              offset: Offset(0, OHelperFunctions.screenHeight() * 0.2),
              child: Stack(
                children: [
                  Transform.scale(
                      scale: 1.4,
                      child: SizedBox(
                          width: OHelperFunctions.screenWidth(),
                          height: OHelperFunctions.screenHeight(),
                          child: Image(
                              fit: BoxFit.cover,
                              image: AssetImage(rectangleImage),
                          ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, OHelperFunctions.screenHeight() * 0.4),
                    child: Padding(
                              padding: const EdgeInsets.all(OSizes.defaultSpace),
                              
                              child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: OSizes.xl),
                                      SizedBox(
                                        width: OHelperFunctions.screenWidth() * 0.7,
                                        child: Text(
                                          title,
                                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      ),
                                      SizedBox(height: OSizes.md),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                             Text(
                                                subTitle,
                                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              SizedBox(height: OSizes.interlineSpacing),
                                              Text(
                                                subTitle2,
                                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              SizedBox(height: OSizes.interlineSpacing),
                                              Text(
                                                subTitle3,
                                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                        ]
                                      ),
                              ],
                            ),
                          ),
                  )
                ]
              )
            ),
            
          ]
        )
      ],
    );
  }
}