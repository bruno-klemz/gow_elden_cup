import 'package:equatable/equatable.dart';

class FavorStep extends Equatable {
  final String id;
  final String title;
  final String detail;
  final String? tip;
  final String? bossId;

  const FavorStep({
    required this.id,
    required this.title,
    required this.detail,
    this.tip,
    this.bossId,
  });

  factory FavorStep.fromJson(Map<String, dynamic> json) => FavorStep(
    id: json['id'] as String,
    title: json['title'] as String,
    detail: json['detail'] as String,
    tip: json['tip'] as String?,
    bossId: json['bossId'] as String?,
  );

  @override
  List<Object?> get props => [id, title, detail, tip, bossId];
}
