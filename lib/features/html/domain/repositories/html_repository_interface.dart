import 'package:makhsos/interfaces/repository_interface.dart';
import 'package:makhsos/util/html_type.dart';

abstract class HtmlRepositoryInterface extends RepositoryInterface {
  Future<dynamic> getHtmlText(HtmlType htmlType);
}
