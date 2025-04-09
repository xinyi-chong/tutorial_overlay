import 'package:flutter/material.dart';

/// Defines a single step in a tutorial, highlighting a widget with a tooltip.
///
/// The [widgetKey] identifies the target widget to highlight, and [child] is
/// displayed in the tooltip. An optional [indicator] (e.g., an arrow) can be
/// positioned above or below the target via [showAbove].
class TutorialStep {
  /// The key of the widget to highlight in the UI.
  final GlobalKey? widgetKey;

  /// The content to display in the tooltip.
  final Widget child;

  /// An optional indicator widget (e.g., an arrow) pointing to the target.
  ///
  /// If null, the default [indicator] from the `TutorialOverlay` will be used.
  final Widget? indicator;

  /// The height of the [indicator].
  ///
  /// If null, the default [indicatorHeight] from the `TutorialOverlay` is used.
  final double? indicatorHeight;

  /// The width of the [indicator].
  ///
  /// If null, the default [indicatorWidth] from the `TutorialOverlay` is used.
  final double? indicatorWidth;

  /// Whether to show the tooltip and indicator above the target (true) or below (false).
  final bool? showAbove;

  /// Padding for the highlight area around the target widget.
  ///
  /// If null, the default [focusOverlayPadding] from the `TutorialOverlay` is used.
  final EdgeInsets? focusOverlayPadding;

  TutorialStep({
    this.widgetKey,
    required this.child,
    this.indicator,
    this.indicatorHeight,
    this.indicatorWidth,
    this.showAbove,
    this.focusOverlayPadding,
  });
}
