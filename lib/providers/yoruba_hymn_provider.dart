import '../data/yoruba_hymns.dart';
import '../models/hymn_data.dart';
import '../repositories/hymn_repository.dart';
import 'hymn_provider.dart';

class YorubaHymnProvider extends IHymnProvider {
  YorubaHymnProvider() : super(HymnRepository('Yoruba_Hymn'));

  @override
  List<HymnData> get dataSource => yorubaHymnData;
}
