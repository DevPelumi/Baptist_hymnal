import '../data/responsive_reading.dart';
import '../models/hymn_data.dart';
import '../repositories/hymn_repository.dart';
import 'hymn_provider.dart';

class ResponsiveReadingProvider extends IHymnProvider {
  ResponsiveReadingProvider() : super(HymnRepository('Responsive_Reading'));

  @override
  List<HymnData> get dataSource => responsive;
}
