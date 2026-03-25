import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/utils/device/device_utility.dart';
import 'package:osho/utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class OModelAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OModelAppBar({
    super.key,
    this.title,
    this.showBackArrow = false,
    this.leadingIcon,
    this.subTitle,
    required this.step,
    required this.totalSteps,
  });

  final Widget? title;
  final Widget? subTitle;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OSizes.defaultPadding),
      child: AppBar(
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: showBackArrow
            ? IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Iconsax.arrow_left, color: isDark ? Colors.white : Colors.black))
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title ?? const SizedBox(),
            subTitle ?? const SizedBox(),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: step / totalSteps,
                  strokeWidth: 3,
                  backgroundColor: OColors.grey.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(OColors.primary),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '0$step',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(width: OSizes.sm),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(ODeviceUtils.getAppBarHeight());
}
