import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:lottie/lottie.dart';
import 'package:makhsos/common/widgets/custom_image.dart';
import 'package:makhsos/common/widgets/custom_ink_well.dart';
import 'package:makhsos/common/widgets/footer_view.dart';
import 'package:makhsos/features/banner/controllers/banner_controller.dart';
import 'package:makhsos/features/home/widgets/web/module_widget.dart';
import 'package:makhsos/features/language/controllers/language_controller.dart';
import 'package:makhsos/features/parcel/controllers/parcel_controller.dart';
import 'package:makhsos/features/parcel/widgets/deliver_item_card_widget.dart';
import 'package:makhsos/features/parcel/widgets/get_service_video_widget.dart';
import 'package:makhsos/features/parcel/widgets/parcel_app_bar_widget.dart';
import 'package:makhsos/features/parcel/widgets/sevice_info_list_widget.dart';
import 'package:makhsos/features/profile/controllers/profile_controller.dart';
import 'package:makhsos/helper/auth_helper.dart';
import 'package:makhsos/helper/responsive_helper.dart';
import 'package:makhsos/helper/route_helper.dart';
import 'package:makhsos/util/dimensions.dart';
import 'package:makhsos/util/styles.dart';

class ParcelCategoryScreen extends StatefulWidget {
  const ParcelCategoryScreen({super.key});

  @override
  State<ParcelCategoryScreen> createState() => _ParcelCategoryScreenState();
}

class _ParcelCategoryScreenState extends State<ParcelCategoryScreen> {
  @override
  void initState() {
    super.initState();
    if (AuthHelper.isLoggedIn() &&
        Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
    Get.find<BannerController>().getParcelOtherBannerList(true);
    Get.find<ParcelController>().getWhyChooseDetails();
    Get.find<ParcelController>().getVideoContentDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context)
          ? null
          : const ParcelAppBarWidget(),
      body: GetBuilder<ParcelController>(builder: (parcelController) {
        return GetBuilder<BannerController>(builder: (bannerController) {
          bool showVideoAndServices = parcelController.videoContentDetails !=
                  null &&
              (parcelController.videoContentDetails!.bannerVideo != null ||
                  parcelController.videoContentDetails!.bannerImageFullUrl !=
                      null);
          return Stack(clipBehavior: Clip.none, children: [
            RefreshIndicator(
              onRefresh: () async {
                await Get.find<ParcelController>().getParcelCategoryList();
                await Get.find<BannerController>()
                    .getParcelOtherBannerList(true);
                await Get.find<ParcelController>().getWhyChooseDetails();
                await Get.find<ParcelController>().getVideoContentDetails();
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context)
                    ? 0
                    : Dimensions.paddingSizeLarge),
                child: FooterView(
                    child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: Column(
                            crossAxisAlignment:
                                ResponsiveHelper.isDesktop(context)
                                    ? CrossAxisAlignment.center
                                    : CrossAxisAlignment.start,
                            children: [
                              // Clean Modern Hero Section
                              _buildHeroSection(context),

                              SizedBox(
                                  height: ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.paddingSizeExtraLarge
                                      : Dimensions.paddingSizeLarge),

                              // New Animated Categories Section
                              _buildAnimatedCategoriesSection(
                                  context, parcelController),
                              const SizedBox(
                                  height: Dimensions.paddingSizeLarge),

                              parcelController.whyChooseDetails != null
                                  ? Container(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.02),
                                      child: GridView.builder(
                                        controller: ScrollController(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: ResponsiveHelper
                                                  .isDesktop(context)
                                              ? 3
                                              : ResponsiveHelper.isTab(context)
                                                  ? 2
                                                  : 1,
                                          crossAxisSpacing:
                                              ResponsiveHelper.isDesktop(
                                                      context)
                                                  ? Dimensions.paddingSizeLarge
                                                  : Dimensions.paddingSizeSmall,
                                          mainAxisSpacing:
                                              ResponsiveHelper.isDesktop(
                                                      context)
                                                  ? Dimensions.paddingSizeLarge
                                                  : Dimensions.paddingSizeSmall,
                                          mainAxisExtent:
                                              ResponsiveHelper.isDesktop(
                                                      context)
                                                  ? 95
                                                  : 80,
                                        ),
                                        itemCount: parcelController
                                            .whyChooseDetails!.banners!.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          return DeliverItemCardWidget(
                                            image:
                                                '${parcelController.whyChooseDetails!.banners![index].imageFullUrl}',
                                            itemName: parcelController
                                                .whyChooseDetails!
                                                .banners![index]
                                                .title!,
                                            description: parcelController
                                                .whyChooseDetails!
                                                .banners![index]
                                                .shortDescription!,
                                          );
                                        },
                                      ),
                                    )
                                  : ParcelShimmer(
                                      isEnabled:
                                          parcelController.parcelCategoryList ==
                                              null,
                                      isDeliveryItem: false),
                              const SizedBox(
                                  height: Dimensions.paddingSizeLarge),

                              Align(
                                alignment:
                                    Get.find<LocalizationController>().isLtr
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                child: Text('easiest_way_to_get_services'.tr,
                                    style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeLarge)),
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeLarge),

                              parcelController.videoContentDetails != null
                                  ? ResponsiveHelper.isDesktop(context)
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                              showVideoAndServices
                                                  ? Expanded(
                                                      child: parcelController
                                                                  .videoContentDetails!
                                                                  .bannerType ==
                                                              'image'
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusSmall),
                                                              child:
                                                                  CustomImage(
                                                                image:
                                                                    '${parcelController.videoContentDetails!.bannerImageFullUrl}',
                                                              ),
                                                            )
                                                          : parcelController
                                                                      .videoContentDetails!
                                                                      .bannerType ==
                                                                  'video'
                                                              ? GetServiceVideoWidget(
                                                                  youtubeVideoUrl:
                                                                      parcelController
                                                                              .videoContentDetails!
                                                                              .bannerVideo ??
                                                                          '',
                                                                  fileVideoUrl:
                                                                      '',
                                                                )
                                                              : GetServiceVideoWidget(
                                                                  youtubeVideoUrl:
                                                                      '',
                                                                  fileVideoUrl:
                                                                      '${parcelController.videoContentDetails!.bannerVideoContentFullUrl}',
                                                                ),
                                                    )
                                                  : const SizedBox(),
                                              const SizedBox(width: 125),
                                              Expanded(
                                                child: ServiceInfoListWidget(
                                                  parcelController:
                                                      parcelController,
                                                ),
                                              ),
                                            ])
                                      : Column(children: [
                                          parcelController.videoContentDetails!
                                                      .bannerType ==
                                                  'image'
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusSmall),
                                                  child: CustomImage(
                                                    image:
                                                        '${parcelController.videoContentDetails!.bannerImageFullUrl}',
                                                  ),
                                                )
                                              : parcelController
                                                          .videoContentDetails!
                                                          .bannerType ==
                                                      'video'
                                                  ? GetServiceVideoWidget(
                                                      youtubeVideoUrl:
                                                          parcelController
                                                                  .videoContentDetails!
                                                                  .bannerVideo ??
                                                              '',
                                                      fileVideoUrl: '',
                                                    )
                                                  : GetServiceVideoWidget(
                                                      youtubeVideoUrl: '',
                                                      fileVideoUrl:
                                                          '${parcelController.videoContentDetails!.bannerVideoContentFullUrl}',
                                                    ),
                                          const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeLarge),
                                          ServiceInfoListWidget(
                                              parcelController:
                                                  parcelController),
                                        ])
                                  : const VideoContentDetailsShimmer(),

                              SizedBox(
                                  height: ResponsiveHelper.isDesktop(context)
                                      ? 0
                                      : 100),
                            ]))),
              ),
            ),
            ResponsiveHelper.isDesktop(context)
                ? const Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(child: ModuleWidget()))
                : const SizedBox(),
          ]);
        });
      }),
    );
  }

  // Clean Modern Hero Section
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Header with logo and title
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Logo and Truck in a clean row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/image/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Truck Animation
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Lottie.asset(
                        'assets/animations/Delivery Truck animation.json',
                        fit: BoxFit.contain,
                        repeat: true,
                        animate: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Module Title
                Text(
                  'اطلب واتمني',
                  style: robotoBold.copyWith(
                    fontSize: ResponsiveHelper.isDesktop(context) ? 28 : 24,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Order & Wish',
                  style: robotoMedium.copyWith(
                    fontSize: ResponsiveHelper.isDesktop(context) ? 16 : 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'bringing_happiness_from_door_to_door'.tr,
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(
                    fontSize: ResponsiveHelper.isDesktop(context) ? 14 : 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Clean Categories Section
  Widget _buildAnimatedCategoriesSection(
      BuildContext context, ParcelController parcelController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'ready_to_send_something_special'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),

          // Categories Grid
          parcelController.parcelCategoryList != null
              ? parcelController.parcelCategoryList!.isNotEmpty
                  ? GridView.builder(
                      controller: ScrollController(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            ResponsiveHelper.isDesktop(context) ? 3 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 120,
                      ),
                      itemCount: parcelController.parcelCategoryList!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return CustomInkWell(
                          onTap: () {
                            Get.toNamed(RouteHelper.getParcelLocationRoute(
                                parcelController.parcelCategoryList![index]));
                          },
                          radius: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.1),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CustomImage(
                                      image:
                                          '${parcelController.parcelCategoryList![index].imageFullUrl}',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    parcelController
                                        .parcelCategoryList![index].name!,
                                    style: robotoMedium.copyWith(
                                      fontSize: 13,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'no_parcel_category_found'.tr,
                              style: robotoRegular.copyWith(
                                color: Colors.grey.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
              : ParcelShimmer(
                  isEnabled: parcelController.parcelCategoryList == null,
                  isDeliveryItem: true,
                ),
        ],
      ),
    );
  }
}

class ParcelShimmer extends StatelessWidget {
  final bool isEnabled;
  final bool isDeliveryItem;
  const ParcelShimmer(
      {super.key, required this.isEnabled, required this.isDeliveryItem});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: isDeliveryItem
          ? SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : 2,
              crossAxisSpacing: ResponsiveHelper.isDesktop(context)
                  ? Dimensions.paddingSizeLarge
                  : Dimensions.paddingSizeSmall,
              mainAxisSpacing: ResponsiveHelper.isDesktop(context)
                  ? Dimensions.paddingSizeLarge
                  : Dimensions.paddingSizeSmall,
              mainAxisExtent: ResponsiveHelper.isDesktop(context) ? 100 : 75,
            )
          : SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveHelper.isDesktop(context)
                  ? 3
                  : ResponsiveHelper.isTab(context)
                      ? 2
                      : 1,
              crossAxisSpacing: ResponsiveHelper.isDesktop(context)
                  ? Dimensions.paddingSizeLarge
                  : Dimensions.paddingSizeSmall,
              mainAxisSpacing: ResponsiveHelper.isDesktop(context)
                  ? Dimensions.paddingSizeLarge
                  : Dimensions.paddingSizeSmall,
              mainAxisExtent: ResponsiveHelper.isDesktop(context) ? 100 : 80,
            ),
      itemCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: isEnabled,
            child: Row(children: [
              Container(
                height: 50,
                width: 50,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                    color: Colors.grey[300], shape: BoxShape.circle),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Container(height: 15, width: 200, color: Colors.grey[300]),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Container(height: 15, width: 100, color: Colors.grey[300]),
                  ])),
              const SizedBox(width: Dimensions.paddingSizeSmall),
            ]),
          ),
        );
      },
    );
  }
}

class VideoContentDetailsShimmer extends StatelessWidget {
  const VideoContentDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 350,
                padding:
                    const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
            ),
            const SizedBox(width: 125),
            Expanded(
              child: ListView.builder(
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            height: 14,
                            width: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Container(
                              height: 15, width: 200, color: Colors.grey[300]),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeSmall,
                              horizontal: 22.5),
                          margin: const EdgeInsets.only(left: 7),
                          decoration: BoxDecoration(
                              border: index == 6 - 1
                                  ? null
                                  : Border(
                                      left: BorderSide(
                                          width: 1,
                                          color: Theme.of(context)
                                              .disabledColor))),
                          child: Container(
                              height: 15, width: 100, color: Colors.grey[300]),
                        ),
                      ]);
                },
              ),
            ),
          ])
        : Column(children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 185,
              padding:
                  const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            ListView.builder(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              itemCount: 6,
              itemBuilder: (context, index) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          height: 14,
                          width: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Container(
                            height: 15, width: 200, color: Colors.grey[300]),
                      ]),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall,
                            horizontal: 22.5),
                        margin: const EdgeInsets.only(left: 7),
                        decoration: BoxDecoration(
                            border: index == 6 - 1
                                ? null
                                : Border(
                                    left: BorderSide(
                                        width: 1,
                                        color:
                                            Theme.of(context).disabledColor))),
                        child: Container(
                            height: 15, width: 100, color: Colors.grey[300]),
                      ),
                    ]);
              },
            ),
          ]);
  }
}

// New Hero Section with Animation
Widget _buildHeroSection(BuildContext context) {
  return Container(
    width: double.infinity,
    height: ResponsiveHelper.isDesktop(context) ? 500 : 400,
    decoration: BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topLeft,
        radius: 1.5,
        colors: [
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor.withOpacity(0.8),
          Theme.of(context).primaryColor.withOpacity(0.6),
          Theme.of(context).primaryColor.withOpacity(0.3),
          Colors.transparent,
        ],
      ),
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          blurRadius: 30,
          spreadRadius: 5,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Stack(
      children: [
        // Animated geometric shapes
        ...List.generate(12, (index) => _buildGeometricShape(context, index)),

        // Animated gradient orbs
        ...List.generate(6, (index) => _buildGradientOrb(context, index)),

        // Main content
        Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Enhanced Logo and Truck Section
              _buildEnhancedLogoSection(context),

              const SizedBox(height: 40),

              // Module Name with 3D effect
              _build3DModuleName(context),

              const SizedBox(height: 25),

              // Animated Description with glow effect
              _buildGlowingDescription(context),

              const SizedBox(height: 30),

              // Interactive action button
              _buildInteractiveButton(context),
            ],
          ),
        ),
      ],
    ),
  );
}

// Animated geometric shapes
Widget _buildGeometricShape(BuildContext context, int index) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: Duration(milliseconds: 3000 + (index * 200)),
    builder: (context, value, child) {
      return Positioned(
        top: 20 + (index * 35) % 300,
        left: 10 + (index * 50) % 350,
        child: Transform.rotate(
          angle: value * 2 * pi,
          child: Transform.scale(
            scale: 0.5 + (value * 0.5),
            child: Opacity(
              opacity: (1 - value) * 0.4,
              child: Container(
                width: 20 + (index % 4) * 10,
                height: 20 + (index % 4) * 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: index % 3 == 0 ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius:
                      index % 3 != 0 ? BorderRadius.circular(8) : null,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

// Animated gradient orbs
Widget _buildGradientOrb(BuildContext context, int index) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: Duration(milliseconds: 4000 + (index * 500)),
    builder: (context, value, child) {
      return Positioned(
        top: 50 + (index * 60) % 250,
        right: 20 + (index * 40) % 200,
        child: Transform.translate(
          offset: Offset(
            (value - 0.5) * 80 * (index % 2 == 0 ? 1 : -1),
            (value - 0.5) * 40 * (index % 3 == 0 ? 1 : -1),
          ),
          child: Opacity(
            opacity: (1 - value) * 0.3,
            child: Container(
              width: 40 + (index % 3) * 20,
              height: 40 + (index % 3) * 20,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// Enhanced logo section
Widget _buildEnhancedLogoSection(BuildContext context) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 2500),
    builder: (context, value, child) {
      return Transform.scale(
        scale: 0.7 + (value * 0.3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3D Logo with holographic effect
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 3),
              builder: (context, hologramValue, child) {
                return Transform.rotate(
                  angle: hologramValue * 0.1,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 25,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(-5, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/image/logo.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(width: 40),

            // Enhanced Truck Animation with 3D effect
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 4),
              builder: (context, rotateValue, child) {
                return Transform.rotate(
                  angle: (rotateValue * 0.2) * (1 - rotateValue),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Lottie.asset(
                      'assets/animations/Delivery Truck animation.json',
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

// 3D Module Name with holographic effect
Widget _build3DModuleName(BuildContext context) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 3000),
    builder: (context, value, child) {
      return Transform.scale(
        scale: 0.3 + (value * 0.7),
        child: Opacity(
          opacity: value,
          child: Column(
            children: [
              // Arabic text with 3D holographic effect
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 3500),
                builder: (context, hologramValue, child) {
                  return Transform.translate(
                    offset: Offset(0, 15 * (1 - hologramValue)),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.8),
                          Colors.white.withOpacity(0.6),
                          Colors.white.withOpacity(0.8),
                          Colors.white,
                        ],
                        stops: [0.0, 0.3, 0.5, 0.7, 1.0],
                      ).createShader(bounds),
                      child: Text(
                        'اطلب واتمني',
                        style: robotoBold.copyWith(
                          fontSize:
                              ResponsiveHelper.isDesktop(context) ? 48 : 36,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(3, 3),
                              blurRadius: 6,
                            ),
                            Shadow(
                              color: Colors.white.withOpacity(0.8),
                              offset: const Offset(-2, -2),
                              blurRadius: 4,
                            ),
                            Shadow(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.6),
                              offset: const Offset(0, 0),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              // English text with neon effect
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 2500),
                builder: (context, neonValue, child) {
                  return Text(
                    'Order & Wish',
                    style: robotoMedium.copyWith(
                      fontSize: ResponsiveHelper.isDesktop(context) ? 26 : 20,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                        Shadow(
                          color: Colors.white.withOpacity(0.6),
                          offset: const Offset(-1, -1),
                          blurRadius: 3,
                        ),
                        Shadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.4),
                          offset: const Offset(0, 0),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Glowing description
Widget _buildGlowingDescription(BuildContext context) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 3500),
    builder: (context, value, child) {
      return Transform.translate(
        offset: Offset(0, 40 * (1 - value)),
        child: Opacity(
          opacity: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Text(
              'bringing_happiness_from_door_to_door'.tr,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: ResponsiveHelper.isDesktop(context) ? 20 : 18,
                color: Colors.white.withOpacity(0.95),
                height: 1.7,
                letterSpacing: 1.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                  Shadow(
                    color: Colors.white.withOpacity(0.3),
                    offset: const Offset(-1, -1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// Interactive button with magnetic effect
Widget _buildInteractiveButton(BuildContext context) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 2500),
    builder: (context, value, child) {
      return Transform.scale(
        scale: value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(-5, -5),
              ),
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.rocket_launch_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Start Your Journey',
                style: robotoMedium.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 1.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// New Animated Categories Section
Widget _buildAnimatedCategoriesSection(
    BuildContext context, ParcelController parcelController) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Section Title with Animation
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(-50 * (1 - value), 0),
            child: Opacity(
              opacity: value,
              child: Text(
                'ready_to_send_something_special'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          );
        },
      ),

      const SizedBox(height: Dimensions.paddingSizeLarge),

      // Animated Grid
      parcelController.parcelCategoryList != null
          ? parcelController.parcelCategoryList!.isNotEmpty
              ? GridView.builder(
                  controller: ScrollController(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : 2,
                    crossAxisSpacing: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeLarge
                        : Dimensions.paddingSizeSmall,
                    mainAxisSpacing: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeLarge
                        : Dimensions.paddingSizeSmall,
                    mainAxisExtent:
                        ResponsiveHelper.isDesktop(context) ? 120 : 100,
                  ),
                  itemCount: parcelController.parcelCategoryList!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 800 + (index * 200)),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: CustomInkWell(
                              onTap: () {
                                Get.toNamed(RouteHelper.getParcelLocationRoute(
                                    parcelController
                                        .parcelCategoryList![index]));
                              },
                              radius: Dimensions.radiusDefault,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CustomImage(
                                          image:
                                              '${parcelController.parcelCategoryList![index].imageFullUrl}',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      parcelController
                                          .parcelCategoryList![index].name!,
                                      style: robotoMedium.copyWith(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : Center(
                  child: Text('no_parcel_category_found'.tr),
                )
          : ParcelShimmer(
              isEnabled: parcelController.parcelCategoryList == null,
              isDeliveryItem: true,
            ),
    ],
  );
}

// Custom painter for animated waves
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height * 0.7);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.7 +
          waveHeight * sin(animationValue * 2 * 3.14159 * x / waveLength);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
