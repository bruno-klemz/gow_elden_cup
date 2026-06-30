import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_theme.dart';
import '../../domain/entity/favor.dart';
import 'bloc/favor_details_bloc.dart';
import 'widgets/diary_header.dart';
import 'widgets/rewards_footer.dart';
import 'widgets/step_entry.dart';

/// Diary-style detail view for a favor. Reads [FavorDetailsBloc] from context.
class FavorDetailsView extends StatelessWidget {
  const FavorDetailsView({super.key, required this.favor});

  final Favor favor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.goldLight),
        title: Text(favor.name, style: AppText.title),
        centerTitle: false,
      ),
      body: BlocBuilder<FavorDetailsBloc, FavorDetailsState>(
        builder: (context, state) {
          final bloc = context.read<FavorDetailsBloc>();
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DiaryHeader(
                  name: favor.name,
                  realm: favor.realm,
                  region: favor.region,
                  giver: favor.giver,
                  sealText: state.sealText(favor),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(favor.summary, style: AppText.lore),
                      if (favor.lore.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          favor.lore,
                          style: AppText.lore.copyWith(
                            color: AppColors.textBody,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('📋 PASSOS', style: AppText.sectionLabel),
                const SizedBox(height: 8),
                ...favor.steps.map(
                  (step) => StepEntry(
                    step: step,
                    isChecked: state.progress.isStepDone(favor.id, step.id),
                    onChanged: (_) =>
                        bloc.add(FavorStepToggled(step.id)),
                  ),
                ),
                RewardsFooter(rewards: favor.rewards),
              ],
            ),
          );
        },
      ),
    );
  }
}
