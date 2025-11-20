import 'package:makhsos/helper/responsive_helper.dart';
import 'package:makhsos/helper/route_helper.dart';
import 'package:makhsos/util/dimensions.dart';
import 'package:makhsos/util/styles.dart';
import 'package:makhsos/common/widgets/cart_widget.dart';
import 'package:makhsos/common/widgets/veg_filter_widget.dart';
import 'package:makhsos/common/widgets/web_menu_bar.dart';
import 'package:makhsos/features/notification/controllers/notification_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool backButton;
  final Function? onBackPressed;
  final bool showCart;
  final Function(String value)? onVegFilterTap;
  final String? type;
  final String? leadingIcon;
  final bool showNotification;
  const CustomAppBar(
      {super.key,
      required this.title,
      this.backButton = true,
      this.onBackPressed,
      this.showCart = false,
      this.leadingIcon,
      this.onVegFilterTap,
      this.type,
      this.showNotification = false});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? const WebMenuBar()
        : AppBar(
            title: Text(title,
                style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge!.color)),
            centerTitle: true,
            leading: backButton
                ? IconButton(
                    icon: leadingIcon != null
                        ? Image.asset(leadingIcon!, height: 22, width: 22)
                        : const Icon(Icons.arrow_back_ios),
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    onPressed: () => onBackPressed != null
                        ? onBackPressed!()
                        : Navigator.pop(context),
                  )
                : const SizedBox(),
            backgroundColor: Theme.of(context).cardColor,
            surfaceTintColor: Theme.of(context).cardColor,
            shadowColor: Theme.of(context).disabledColor.withOpacity(0.5),
            elevation: 2,
            actions: showCart || onVegFilterTap != null || showNotification
                ? [
                    showCart
                        ? IconButton(
                            onPressed: () =>
                                Get.toNamed(RouteHelper.getCartRoute()),
                            icon: CartWidget(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                                size: 25),
                          )
                        : const SizedBox(),
                    onVegFilterTap != null
                        ? VegFilterWidget(
                            type: type,
                            onSelected: onVegFilterTap,
                            fromAppBar: true,
                          )
                        : const SizedBox(),
                    showNotification
                        ? InkWell(
                            child: GetBuilder<NotificationController>(
                                builder: (notificationController) {
                              return Stack(children: [
                                Icon(CupertinoIcons.bell,
                                    size: 25,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color),
                                notificationController.hasNotification
                                    ? Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                width: 1,
                                                color: Theme.of(context)
                                                    .cardColor),
                                          ),
                                        ))
                                    : const SizedBox(),
                              ]);
                            }),
                            onTap: () =>
                                Get.toNamed(RouteHelper.getNotificationRoute()),
                          )
                        : const SizedBox(),
                  ]
                : [const SizedBox()],
          );
  }

  @override
  Size get preferredSize => Size(Get.width, GetPlatform.isDesktop ? 100 : 50);
}
