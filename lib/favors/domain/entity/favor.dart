import 'package:equatable/equatable.dart';

import 'favor_step.dart';
import 'reward.dart';

class Favor extends Equatable {
  final String id;
  final String name;
  final String realm;
  final String? region;
  final String? giver;
  final String summary;
  final String lore;
  final List<FavorStep> steps;
  final List<Reward> rewards;
  final bool needsReview;

  const Favor({
    required this.id,
    required this.name,
    required this.realm,
    this.region,
    this.giver,
    required this.summary,
    required this.lore,
    this.steps = const [],
    this.rewards = const [],
    this.needsReview = false,
  });

  List<String> get stepIds => steps.map((s) => s.id).toList();

  factory Favor.fromJson(Map<String, dynamic> json) => Favor(
        id: json['id'] as String,
        name: json['name'] as String,
        realm: json['realm'] as String,
        region: json['region'] as String?,
        giver: json['giver'] as String?,
        summary: json['summary'] as String,
        lore: json['lore'] as String,
        steps: ((json['steps'] as List?) ?? const [])
            .map((e) => FavorStep.fromJson(e as Map<String, dynamic>))
            .toList(),
        rewards: ((json['rewards'] as List?) ?? const [])
            .map((e) => Reward.fromJson(e as Map<String, dynamic>))
            .toList(),
        needsReview: json['needsReview'] as bool? ?? false,
      );

  @override
  List<Object?> get props =>
      [id, name, realm, region, giver, summary, lore, steps, rewards, needsReview];
}
