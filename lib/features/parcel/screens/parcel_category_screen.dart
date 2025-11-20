import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makhsos/common/widgets/menu_drawer.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:makhsos/common/widgets/custom_image.dart';
import 'package:makhsos/common/widgets/custom_ink_well.dart';
import 'package:makhsos/features/banner/controllers/banner_controller.dart';
import 'package:makhsos/features/language/controllers/language_controller.dart';
import 'package:makhsos/features/parcel/controllers/parcel_controller.dart';
import 'package:makhsos/features/parcel/widgets/deliver_item_card_widget.dart';
import 'package:makhsos/features/parcel/widgets/get_service_video_widget.dart';
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
      body: GetBuilder<ParcelController>(builder: (parcelController) {
        return GetBuilder<BannerController>(builder: (bannerController) {
          bool showVideoAndServices = parcelController.videoContentDetails !=
                  null &&
              (parcelController.videoContentDetails!.bannerVideo != null ||
                  parcelController.videoContentDetails!.bannerImageFullUrl !=
                      null);
          return CustomScrollView(
            slivers: [
              // Custom Sliver App Bar with Image
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'order_and_wish'.tr,
                    style: robotoMedium.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                  titlePadding:
                      const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Parcel image taking full space
                      Image.asset(
                        'assets/image/beeb_parcel.png',
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay for better text readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Get.find<ParcelController>().getParcelCategoryList();
                    await Get.find<BannerController>()
                        .getParcelOtherBannerList(true);
                    await Get.find<ParcelController>().getWhyChooseDetails();
                    await Get.find<ParcelController>().getVideoContentDetails();
                  },
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context)
                        ? 0
                        : Dimensions.paddingSizeLarge),
                    child: Column(
                        crossAxisAlignment: ResponsiveHelper.isDesktop(context)
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.paddingSizeExtraLarge
                                  : Dimensions.paddingSizeLarge),

                          // Categories Section
                          _buildAnimatedCategoriesSection(
                              context, parcelController),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          parcelController.whyChooseDetails != null
                              ? Container(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.02),
                                  child: GridView.builder(
                                    controller: ScrollController(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          ResponsiveHelper.isDesktop(context)
                                              ? 3
                                              : ResponsiveHelper.isTab(context)
                                                  ? 2
                                                  : 1,
                                      crossAxisSpacing:
                                          ResponsiveHelper.isDesktop(context)
                                              ? Dimensions.paddingSizeLarge
                                              : Dimensions.paddingSizeSmall,
                                      mainAxisSpacing:
                                          ResponsiveHelper.isDesktop(context)
                                              ? Dimensions.paddingSizeLarge
                                              : Dimensions.paddingSizeSmall,
                                      mainAxisExtent:
                                          ResponsiveHelper.isDesktop(context)
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
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Align(
                            alignment: Get.find<LocalizationController>().isLtr
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Text('easiest_way_to_get_services'.tr,
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge)),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

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
                                                          borderRadius: BorderRadius
                                                              .circular(Dimensions
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
                                                      Dimensions.radiusSmall),
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
                                                  youtubeVideoUrl: parcelController
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
                                          height: Dimensions.paddingSizeLarge),
                                      ServiceInfoListWidget(
                                          parcelController: parcelController),
                                    ])
                              : const VideoContentDetailsShimmer(),

                          SizedBox(
                              height: ResponsiveHelper.isDesktop(context)
                                  ? 0
                                  : 100),
                        ]),
                  ),
                ),
              ),
            ],
          );
        });
      }),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
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
                            Get.toNamed(RouteHelper.getParcelUnifiedRoute(
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
