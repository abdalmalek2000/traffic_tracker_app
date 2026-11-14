import 'package:flutter/material.dart';

/// Reusable interactive resizable split view for tablet layouts.
/// Provides a draggable divider clamped strictly between [minRatio] (default 0.30)
/// and [maxRatio] (default 0.70) to prevent layout collapse.
class TabletResizableSplitView extends StatefulWidget {
  final Widget leftChild;
  final Widget rightChild;
  final double initialRatio;
  final double minRatio;
  final double maxRatio;
  final ValueChanged<double>? onRatioChanged;

  const TabletResizableSplitView({
    super.key,
    required this.leftChild,
    required this.rightChild,
    this.initialRatio = 0.40,
    this.minRatio = 0.30,
    this.maxRatio = 0.70,
    this.onRatioChanged,
  });

  @override
  State<TabletResizableSplitView> createState() =>
      _TabletResizableSplitViewState();
}

class _TabletResizableSplitViewState extends State<TabletResizableSplitView> {
  late double _ratio;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio.clamp(widget.minRatio, widget.maxRatio);
  }

  @override
  void didUpdateWidget(covariant TabletResizableSplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRatio != widget.initialRatio) {
      _ratio = widget.initialRatio.clamp(widget.minRatio, widget.maxRatio);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const dividerWidth = 12.0;
        final availableWidth = (totalWidth - dividerWidth).clamp(0.0, double.infinity);

        final leftWidth = availableWidth * _ratio;
        final rightWidth = (availableWidth - leftWidth).clamp(0.0, double.infinity);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left pane
            SizedBox(
              width: leftWidth,
              child: widget.leftChild,
            ),

            // Interactive Draggable Divider
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (_) => setState(() => _isDragging = true),
                onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
                onHorizontalDragCancel: () => setState(() => _isDragging = false),
                onHorizontalDragUpdate: (details) {
                  final delta = isRtl ? -details.primaryDelta! : details.primaryDelta!;
                  setState(() {
                    final newRatio = _ratio + (delta / availableWidth);
                    _ratio = newRatio.clamp(widget.minRatio, widget.maxRatio);
                  });
                  widget.onRatioChanged?.call(_ratio);
                },
                child: SizedBox(
                  width: dividerWidth,
                  child: Center(
                    child: Container(
                      width: _isDragging ? 3.0 : 1.5,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: _isDragging
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Right pane
            SizedBox(
              width: rightWidth,
              child: widget.rightChild,
            ),
          ],
        );
      },
    );
  }
}
