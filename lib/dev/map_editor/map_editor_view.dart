import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/map_editor_bloc.dart';
import 'bloc/map_editor_state.dart';

/// Dev-only editor: pick a realm, pick a boss, tap the map to record its
/// normalized (x,y). Export writes map_coords.json + prints it.
class MapEditorView extends StatelessWidget {
  const MapEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapEditorBloc, MapEditorState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final bloc = context.read<MapEditorBloc>();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Map Coord Editor (dev)'),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => bloc.add(CoordsExported()),
              ),
            ],
          ),
          body: Column(
            children: [
              _RealmBar(state: state, bloc: bloc),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 160,
                      child: _BossList(state: state, bloc: bloc),
                    ),
                    Expanded(child: _MapCanvas(state: state, bloc: bloc)),
                  ],
                ),
              ),
              if (state.exportedPath != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('Saved: ${state.exportedPath}'),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RealmBar extends StatelessWidget {
  const _RealmBar({required this.state, required this.bloc});
  final MapEditorState state;
  final MapEditorBloc bloc;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final r in state.realms)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: ChoiceChip(
                label: Text(r.name),
                selected: r.id == state.selectedRealmId,
                onSelected: (_) => bloc.add(RealmSelected(r.id)),
              ),
            ),
        ],
      ),
    );
  }
}

class _BossList extends StatelessWidget {
  const _BossList({required this.state, required this.bloc});
  final MapEditorState state;
  final MapEditorBloc bloc;

  @override
  Widget build(BuildContext context) {
    final bosses = state.bossesForSelectedRealm;
    return ListView(
      children: [
        for (final b in bosses)
          ListTile(
            dense: true,
            selected: b.id == state.selectedBossId,
            title: Text(b.name),
            subtitle: Text(
              state.coords[b.id] == null
                  ? '—'
                  : '${state.coords[b.id]!.x.toStringAsFixed(3)}, '
                      '${state.coords[b.id]!.y.toStringAsFixed(3)}',
            ),
            onTap: () => bloc.add(BossSelected(b.id)),
          ),
      ],
    );
  }
}

class _MapCanvas extends StatelessWidget {
  const _MapCanvas({required this.state, required this.bloc});
  final MapEditorState state;
  final MapEditorBloc bloc;

  @override
  Widget build(BuildContext context) {
    final realm = state.realms
        .where((r) => r.id == state.selectedRealmId)
        .toList();
    final mapImage = realm.isEmpty ? null : realm.first.mapImage;
    if (mapImage == null) {
      return const Center(child: Text('Pick a realm'));
    }
    final placed = state.selectedBossId == null
        ? null
        : state.coords[state.selectedBossId];
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: (details) {
            final x = (details.localPosition.dx / constraints.maxWidth)
                .clamp(0.0, 1.0);
            final y = (details.localPosition.dy / constraints.maxHeight)
                .clamp(0.0, 1.0);
            bloc.add(CoordPlaced(x, y));
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/$mapImage',
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) =>
                      const ColoredBox(color: Color(0xFF14201A)),
                ),
              ),
              if (placed != null)
                Positioned(
                  left: placed.x * constraints.maxWidth - 14,
                  top: placed.y * constraints.maxHeight - 28,
                  child: const Text('📍', style: TextStyle(fontSize: 28)),
                ),
            ],
          ),
        );
      },
    );
  }
}
