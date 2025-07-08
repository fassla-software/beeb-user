import 'package:makhsos/common/enums/data_source_enum.dart';
import 'package:makhsos/features/brands/domain/models/brands_model.dart';
import 'package:makhsos/features/item/domain/models/item_model.dart';
import 'package:makhsos/interfaces/repository_interface.dart';

abstract class BrandsRepositoryInterface extends RepositoryInterface {
  Future<ItemModel?> getBrandItemList({required int brandId, int? offset});
  Future<List<BrandModel>?> getBrandList({required DataSourceEnum source});
}
