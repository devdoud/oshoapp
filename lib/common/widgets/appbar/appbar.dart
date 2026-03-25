import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/utils/device/device_utility.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import '../../../utils/constants/sizes.dart';

class OAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OAppBar(
      {super.key,
      this.title,
      this.actions,
      this.leadingIcon,
      this.leadingOnPressed,
      this.showBackArrow = true, 
      this.subTitle});

  final Widget? title;
  final Widget? subTitle;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final canPop = Navigator.canPop(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OSizes.defaultPadding),
      child: AppBar(
          systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          automaticallyImplyLeading: false,
          leading: (showBackArrow && canPop)
              ? IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Iconsax.arrow_left, color: isDark ? Colors.white : Colors.black))
              : leadingIcon != null
                  ? IconButton(
                      onPressed: leadingOnPressed, icon: Icon(leadingIcon, color: isDark ? Colors.white : Colors.black))
                  : null,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) title!,
              if (subTitle != null) subTitle!,
            ],
          ),
          actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(ODeviceUtils.getAppBarHeight());
}
