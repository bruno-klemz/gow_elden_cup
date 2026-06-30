import 'package:equatable/equatable.dart';

class Reward extends Equatable {
  final String name;
  final String? rarity;
  final int? quantity;

  const Reward({required this.name, this.rarity, this.quantity});

  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
        name: json['name'] as String,
        rarity: json['rarity'] as String?,
        quantity: json['quantity'] as int?,
      );

  @override
  List<Object?> get props => [name, rarity, quantity];
}
