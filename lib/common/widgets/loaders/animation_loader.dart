import 'package:flutter/material.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:lottie/lottie.dart';

/// A widget for dsplaying an animated loading indicator with optional text and action button.
class OAnimationLoaderWidget extends StatelessWidget {
  /// Default constructor  for the OAnimationLoaderWdget
  /// 
  /// Parameters
  ///  - text: The text to be displayed bellow the animation.
  ///  - animation: The path to the Lottie animation file
  ///  - showAction: Whether to show an action button bellow the text
  ///  - actionText: The text to be displayed on the action button
  ///  - onActionPressed: Callback function to be executed when the ction button ispressed.
  const OAnimationLoaderWidget({
    super.key,
    required this.text,
    required this.animation,
    this.showAction = false,
    this.actionText,
    this.onActionPressed   
  });


  final String text;
  final String animation;
  final bool showAction;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(animation, width: MediaQuery.of(context).size.width * 0.8),
          const SizedBox(height: OSizes.defaultPadding),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: OSizes.defaultPadding),
          showAction
           ? SizedBox(
             width: 250,
             child: OutlinedButton(
              onPressed: onActionPressed,
              style: OutlinedButton.styleFrom(backgroundColor: OColors.primary),
              child: Text(
                actionText!,
                style: Theme.of(context).textTheme.bodyMedium!.apply(color: OColors.white),
              ),
             ),
           )
           : SizedBox(),
        ],
      ),
    );
  }
}