import 'package:flutter/material.dart';

/// Defines a single step in a tutorial.
class TutorialStep {
  /// The instructional content to show in the tooltip.
  final Widget child;

  /// The key of the target widget to highlight.
  ///
  /// If null, no widget is highlighted.
  final GlobalKey? widgetKey;

  /// Forces tooltip position (true = above target, false = below).
  ///
  /// If null, the position is automatically determined based on available screen space.
  final bool? showAbove;

  /// Custom widget that points to the target (e.g., arrow).
  ///
  /// When null, falls back to [TutorialOverlay.indicator].
  /// Requires [indicatorHeight] and [indicatorWidth] for correct positioning.
  ///
  /// {@tool snippet}
  /// ```dart
  /// indicator: Icon(Icons.arrow_downward, size: 24),
  /// indicatorHeight: 24,
  /// indicatorWidth: 24,
  /// ```
  /// {@end-tool}
  final Widget? indicator;

  /// The height of the [indicator].
  ///
  /// When null, falls back to [TutorialOverlay.indicatorHeight].
  /// Required if [indicator] is set.
  final double? indicatorHeight;

  /// The width of the [indicator].
  ///
  /// When null, falls back to [TutorialOverlay.indicatorWidth].
  /// Required if [indicator] is set.
  final double? indicatorWidth;

  /// Padding for the highlighted area around the target widget.
  ///
  /// When null, falls back to [TutorialOverlay.focusOverlayPadding].
  final EdgeInsets? focusOverlayPadding;

  TutorialStep({
    required this.child,
    this.widgetKey,
    this.showAbove,
    this.indicator,
    this.indicatorHeight,
    this.indicatorWidth,
    this.focusOverlayPadding,
  });
}
