import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class LookbackResult {
  static final DateTime _kForever = DateTime(1970);

  final DateTime since;
  LookbackResult({required this.since});
  LookbackResult.forever() : since = _kForever;

  bool get isForever => since.year == 1970;
}

class LookbackPicker extends StatefulWidget {
  final DateTime? lastReviewTimestamp;

  const LookbackPicker({super.key, this.lastReviewTimestamp});

  static Future<LookbackResult?> show(
    BuildContext context, {
    DateTime? lastReviewTimestamp,
  }) {
    return showModalBottomSheet<LookbackResult>(
      context: context,
      builder: (_) => LookbackPicker(
        lastReviewTimestamp: lastReviewTimestamp,
      ),
    );
  }

  @override
  State<LookbackPicker> createState() => _LookbackPickerState();
}

class _LookbackPickerState extends State<LookbackPicker> {
  int? _selectedDays;
  bool _sinceLastReview = false;
  bool _forever = false;

  @override
  void initState() {
    super.initState();
    if (widget.lastReviewTimestamp != null) {
      _sinceLastReview = true;
    } else {
      _selectedDays = 7;
    }
  }

  DateTime _computeCutoff() {
    if (_forever) {
      return DateTime(1970);
    }
    if (_sinceLastReview && widget.lastReviewTimestamp != null) {
      return widget.lastReviewTimestamp!;
    }
    return DateTime.now().subtract(Duration(days: _selectedDays ?? 7));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final hasLastReview = widget.lastReviewTimestamp != null;

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.howFarBack,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceLG),

          if (hasLastReview) ...[
            _PickerChip(
              label: l.sinceLastReview,
              selected: _sinceLastReview,
              onTap: () => setState(() {
                _sinceLastReview = true;
                _forever = false;
                _selectedDays = null;
              }),
            ),
            const SizedBox(height: AppTheme.spaceSM),
          ],

          Wrap(
            spacing: AppTheme.spaceSM,
            runSpacing: AppTheme.spaceSM,
            children: [
              for (final days in [1, 3, 7, 14, 30])
                _PickerChip(
                  label: days == 1 ? l.oneDay : l.nDays(days),
                  selected: !_sinceLastReview && !_forever && _selectedDays == days,
                  onTap: () => setState(() {
                    _sinceLastReview = false;
                    _forever = false;
                    _selectedDays = days;
                  }),
                ),
              _PickerChip(
                label: l.forever,
                selected: _forever,
                onTap: () => setState(() {
                  _sinceLastReview = false;
                  _selectedDays = null;
                  _forever = true;
                }),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spaceLG),

          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              LookbackResult(since: _computeCutoff()),
            ),
            child: Text(l.startReview),
          ),
          const SizedBox(height: AppTheme.spaceSM),
        ],
      ),
    );
  }
}

class _PickerChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PickerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.accent.withAlpha(51),
      labelStyle: TextStyle(
        color: selected ? AppTheme.accent : AppTheme.textPrimary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
