import 'package:equatable/equatable.dart';

import 'favor.dart';

class FavorsData extends Equatable {
  final List<Favor> favors;

  const FavorsData({required this.favors});

  List<Favor> favorsIn(String realmId) =>
      favors.where((f) => f.realm == realmId).toList();

  Favor favorById(String id) => favors.firstWhere((f) => f.id == id);

  @override
  List<Object?> get props => [favors];
}
