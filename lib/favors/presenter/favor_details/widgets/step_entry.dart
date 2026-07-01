import 'package:flutter/material.dart';

import '../../../../favors/domain/entity/favor_step.dart';
import '../favor_text.dart';

/// A quest step as a diary entry with a "wax-stamp" marker instead of a plain
/// checkbox. Tapping toggles completion; when done the stamp box presses in
/// (rotates + glows) with a check and the title is struck through.
class StepEntry extends StatelessWidget {
  const StepEntry({
    super.key,
    required this.step,
    required this.isChecked,
    required this.onChanged,
    required this.accent,
  });

  final FavorStep step;
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final Color accent;

  static const _ink = Color(0xFFF1E4B8);
  static const _inkDim = Color(0xFFC2B288);
  static const _inkBody = Color(0xFFCDBB8C);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isChecked),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0x2BB58A3E))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Stamp(checked: isChecked, accent: accent),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: FavorText.stepTitle.copyWith(
                      color: isChecked ? _inkDim : _ink,
                      decoration:
                          isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    step.detail,
                    style: FavorText.body.copyWith(color: _inkBody),
                  ),
                  if (step.tip != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '💡 ${step.tip}',
                      style: FavorText.body.copyWith(
                        color: accent,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The wax-stamp marker: empty box when pending, pressed-in glowing stamp with
/// a check when done. Animates between the two states.
class _Stamp extends StatelessWidget {
  const _Stamp({required this.checked, required this.accent});

  final bool checked;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      width: 30,
      height: 30,
      transformAlignment: Alignment.center,
      transform: Matrix4.rotationZ(checked ? -0.12 : 0),
      decoration: BoxDecoration(
        color: checked
            ? accent.withValues(alpha: 0.26)
            : const Color(0x66140A04),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: checked ? accent : const Color(0xFF8A6A36),
          width: 1.5,
        ),
        boxShadow: checked
            ? [BoxShadow(color: accent.withValues(alpha: 0.45), blurRadius: 10)]
            : null,
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: checked ? 1 : 0,
        child: Icon(Icons.check, size: 17, color: accent),
      ),
    );
  }
}
