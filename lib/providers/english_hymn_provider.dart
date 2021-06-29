import '../data/english_hymns.dart';
import '../models/hymn_data.dart';
import '../repositories/hymn_repository.dart';
import 'hymn_provider.dart';

class EnglishHymnProvider extends IHymnProvider {
  EnglishHymnProvider() : super(HymnRepository('English_Hymn'));

  @override
  List<HymnData> get dataSource => englishHymnData;
}
