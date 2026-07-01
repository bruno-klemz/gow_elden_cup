import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../boss/domain/usecase/load_progress_usecase.dart';
import '../../../favors/domain/entity/favor.dart';
import '../../../favors/domain/usecase/toggle_favor_step_usecase.dart';
import '../../../service_locator.dart';
import 'bloc/favor_details_bloc.dart';
import 'favor_details_view.dart';

/// Composition root for the favor diary detail screen.
class FavorDetailsScreen extends StatelessWidget {
  const FavorDetailsScreen({super.key, required this.favor});

  final Favor favor;

  /// Pushes the favor details as a full-screen route.
  static Future<void> push(BuildContext context, Favor favor) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => FavorDetailsScreen(favor: favor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FavorDetailsBloc(
        favor: favor,
        loadProgress: locator<LoadProgressUsecase>(),
        toggleStep: locator<ToggleFavorStepUsecase>(),
      )..add(const FavorDetailsStarted()),
      child: FavorDetailsView(favor: favor),
    );
  }
}
