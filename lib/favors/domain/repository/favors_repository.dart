import '../entity/favors_data.dart';

abstract class FavorsRepository {
  Future<FavorsData> load();
}
