import '../entity/favors_data.dart';
import '../repository/favors_repository.dart';

abstract class LoadFavorsUsecase {
  Future<FavorsData> call();
}

class LoadFavorsUsecaseImpl implements LoadFavorsUsecase {
  final FavorsRepository _repository;

  LoadFavorsUsecaseImpl({required FavorsRepository repository})
    : _repository = repository;

  @override
  Future<FavorsData> call() => _repository.load();
}
