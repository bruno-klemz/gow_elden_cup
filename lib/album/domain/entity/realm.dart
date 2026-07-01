import 'package:equatable/equatable.dart';

class Realm extends Equatable {
  final String id;
  final String name;
  final int order;
  final String? mapImage;
  const Realm({
    required this.id,
    required this.name,
    required this.order,
    this.mapImage,
  });

  factory Realm.fromJson(Map<String, dynamic> json) => Realm(
    id: json['id'] as String,
    name: json['name'] as String,
    order: json['order'] as int,
    mapImage: json['mapImage'] as String?,
  );

  @override
  List<Object?> get props => [id, name, order, mapImage];
}
