import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makhsos/features/address/controllers/address_controller.dart';
import 'package:makhsos/features/address/domain/models/address_model.dart';
import 'package:makhsos/features/parcel/controllers/parcel_controller.dart';
import 'package:makhsos/features/parcel/domain/models/parcel_category_model.dart';
import 'package:makhsos/features/location/controllers/location_controller.dart';
import 'package:makhsos/features/location/domain/models/zone_response_model.dart';
import 'package:makhsos/helper/address_helper.dart';
import 'package:makhsos/helper/responsive_helper.dart';
import 'package:makhsos/helper/route_helper.dart';
import 'package:makhsos/util/dimensions.dart';
import 'package:makhsos/util/styles.dart';
import 'package:makhsos/common/widgets/custom_app_bar.dart';
import 'package:makhsos/common/widgets/custom_button.dart';
import 'package:makhsos/common/widgets/custom_snackbar.dart';
import 'package:makhsos/common/widgets/menu_drawer.dart';
import 'package:makhsos/common/widgets/address_widget.dart';
import 'package:makhsos/features/location/screens/pick_map_screen.dart';

class ParcelLocationScreen extends StatefulWidget {
  final ParcelCategoryModel category;
  const ParcelLocationScreen({super.key, required this.category});

  @override
  State<ParcelLocationScreen> createState() => _ParcelLocationScreenState();
}

class _ParcelLocationScreenState extends State<ParcelLocationScreen> {
  // Static sender data
  final String _senderName = 'beeb';
  final String _senderPhone = '01222222222';

  @override
  void initState() {
    super.initState();
    initCall();
  }

  Future<void> initCall() async {
    // Initialize pickup and destination addresses
    Get.find<ParcelController>()
        .setPickupAddress(AddressHelper.getUserAddressFromSharedPref(), false);
    Get.find<ParcelController>().setDestinationAddress(
        AddressHelper.getUserAddressFromSharedPref(),
        notify: false);

    // Set static sender data
    Get.find<ParcelController>().setIsPickedUp(true, false);
    Get.find<ParcelController>().setIsSender(true, false);
    Get.find<ParcelController>().setSenderAddressIndex(0, canUpdate: false);
    Get.find<ParcelController>().setReceiverAddressIndex(0, canUpdate: false);

    // Load address list if user is logged in
    if (Get.find<AddressController>().addressList == null) {
      Get.find<AddressController>().getAddressList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'parcel_location'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: GetBuilder<ParcelController>(builder: (parcelController) {
          return GetBuilder<AddressController>(builder: (addressController) {
            return SingleChildScrollView(
              child: Center(
                child: Container(
                  width: Dimensions.webMaxWidth,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Column(
                    children: [
                      // Pickup Location
                      _buildLocationSection(
                        context: context,
                        title: 'pickup_location'.tr,
                        address: parcelController.pickupAddress,
                        onTap: () => _selectLocation(context, true),
                        onAddNew: () => _addNewLocation(context, true),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      // Destination Location
                      _buildLocationSection(
                        context: context,
                        title: 'delivery_location'.tr,
                        address: parcelController.destinationAddress,
                        onTap: () => _selectLocation(context, false),
                        onAddNew: () => _addNewLocation(context, false),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      // Continue Button
                      _bottomButton(),
                    ],
                  ),
                ),
              ),
            );
          });
        }),
      ),
    );
  }

  Widget _buildLocationSection({
    required BuildContext context,
    required String title,
    required AddressModel? address,
    required VoidCallback onTap,
    required VoidCallback onAddNew,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              TextButton.icon(
                onPressed: onAddNew,
                icon: const Icon(Icons.add, size: 20),
                label: Text(
                  'add_new'.tr,
                  style:
                      robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          GestureDetector(
            onTap: onTap,
            child: Container(
              constraints: BoxConstraints(
                minHeight: ResponsiveHelper.isDesktop(context) ? 90 : 75,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: address != null
                  ? AddressWidget(
                      address: address,
                      fromAddress: false,
                      fromCheckout: true,
                    )
                  : Center(
                      child: Text(
                        'select_location'.tr,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButton() {
    return GetBuilder<ParcelController>(builder: (parcelController) {
      return CustomButton(
        margin: ResponsiveHelper.isDesktop(context)
            ? null
            : const EdgeInsets.all(Dimensions.paddingSizeSmall),
        buttonText: 'continue'.tr,
        onPressed: () async {
          if (parcelController.pickupAddress == null) {
            showCustomSnackBar('select_pickup_address'.tr);
          } else if (parcelController.destinationAddress == null) {
            showCustomSnackBar('select_destination_address'.tr);
          } else {
            // Create sender address with static data
            AddressModel pickup = AddressModel(
              address: parcelController.pickupAddress!.address,
              additionalAddress:
                  parcelController.pickupAddress!.additionalAddress,
              addressType: parcelController.pickupAddress!.addressType,
              contactPersonName: _senderName,
              contactPersonNumber: _senderPhone,
              latitude: parcelController.pickupAddress!.latitude,
              longitude: parcelController.pickupAddress!.longitude,
              method: parcelController.pickupAddress!.method,
              zoneId: parcelController.pickupAddress!.zoneId,
              zoneIds: parcelController.pickupAddress!.zoneIds,
              id: parcelController.pickupAddress!.id,
              zoneData: parcelController.pickupAddress!.zoneData,
            );

            parcelController.setPickupAddress(pickup, true);

            Get.toNamed(RouteHelper.getParcelRequestRoute(
              widget.category,
              parcelController.pickupAddress!,
              parcelController.destinationAddress!,
            ));
          }
        },
      );
    });
  }

  void _selectLocation(BuildContext context, bool isPickup) {
    // This method can be used to show existing addresses if needed
    // For now, we'll just call the add new location method
    _addNewLocation(context, isPickup);
  }

  void _addNewLocation(BuildContext context, bool isPickup) {
    if (ResponsiveHelper.isDesktop(context)) {
      showGeneralDialog(
        context: context,
        pageBuilder: (_, __, ___) {
          return SizedBox(
            height: 300,
            width: 300,
            child: PickMapScreen(
              fromSignUp: false,
              canRoute: false,
              fromAddAddress: false,
              route: '',
              onPicked: (AddressModel address) async {
                ZoneResponseModel responseModel =
                    await Get.find<LocationController>().getZone(
                        address.latitude.toString(),
                        address.longitude.toString(),
                        false);

                AddressModel newAddress = AddressModel(
                  id: address.id,
                  addressType: address.addressType,
                  contactPersonNumber: address.contactPersonNumber,
                  contactPersonName: address.contactPersonName,
                  address: address.address,
                  latitude: address.latitude,
                  longitude: address.longitude,
                  zoneId:
                      responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
                  zoneIds: address.zoneIds,
                  method: address.method,
                  streetNumber: address.streetNumber,
                  house: address.house,
                  floor: address.floor,
                  zoneData: responseModel.zoneData,
                );

                if (isPickup) {
                  Get.find<ParcelController>()
                      .setPickupAddress(newAddress, true);
                } else {
                  Get.find<ParcelController>()
                      .setDestinationAddress(newAddress);
                }
              },
            ),
          );
        },
      );
    } else {
      Get.toNamed(
        RouteHelper.getPickMapRoute('parcel', false),
        arguments: PickMapScreen(
          fromSignUp: false,
          fromAddAddress: false,
          canRoute: false,
          route: '',
          onPicked: (AddressModel address) async {
            ZoneResponseModel responseModel =
                await Get.find<LocationController>().getZone(
                    address.latitude.toString(),
                    address.longitude.toString(),
                    false);

            AddressModel newAddress = AddressModel(
              id: address.id,
              addressType: address.addressType,
              contactPersonNumber: address.contactPersonNumber,
              contactPersonName: address.contactPersonName,
              address: address.address,
              latitude: address.latitude,
              longitude: address.longitude,
              zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
              zoneIds: responseModel.zoneIds,
              method: address.method,
              streetNumber: address.streetNumber,
              house: address.house,
              floor: address.floor,
              zoneData: responseModel.zoneData,
            );

            if (isPickup) {
              Get.find<ParcelController>().setPickupAddress(newAddress, true);
            } else {
              Get.find<ParcelController>().setDestinationAddress(newAddress);
            }
          },
        ),
      );
    }
  }
}
