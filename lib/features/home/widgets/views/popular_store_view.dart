import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makhsos/features/store/controllers/store_controller.dart';
import 'package:makhsos/features/store/domain/models/store_model.dart';
import 'package:makhsos/features/home/widgets/components/popular_store_card_widget.dart';
import 'package:makhsos/helper/route_helper.dart';
import 'package:makhsos/util/dimensions.dart';
import 'package:makhsos/common/widgets/title_widget.dart';
import '../web/web_populer_store_view_widget.dart';

class PopularStoreView extends StatelessWidget {
  const PopularStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: GetBuilder<StoreController>(builder: (storeController) {
        List<Store>? storeList = storeController.popularStoreList;

        return Column(children: [
          Padding(
            padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
                bottom: Dimensions.paddingSizeDefault),
            child: TitleWidget(
              title: 'popular_stores'.tr,
              onTap: () => Get.toNamed(RouteHelper.getAllStoreRoute('popular')),
            ),
          ),
          SizedBox(
            height: 170,
            child: storeList != null
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: storeList.length,
                    padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            right: Dimensions.paddingSizeDefault,
                            bottom: Dimensions.paddingSizeExtraSmall),
                        child: PopularStoreCard(
                          store: storeList[index],
                        ),
                      );
                    },
                  )
                : const PopularStoreShimmer(),
          ),
        ]);
      }),
    );
  }
}
